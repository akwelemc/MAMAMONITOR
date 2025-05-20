import os
import time
import base64
import sqlite3
import io

# For plotting in memory
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

from flask import Flask, request, render_template, redirect, url_for
from scipy.signal import butter, filtfilt
from sklearn.decomposition import FastICA
import numpy as np

import wfdb
import pyedflib
from wfdb.processing import XQRS

app = Flask(__name__)

# Ensure an 'uploads' folder exists for storing incoming EDF files
os.makedirs('uploads', exist_ok=True)

# Initialize SQLite database
con = sqlite3.connect('fetal_data.db', check_same_thread=False)
cur = con.cursor()
cur.execute('''
    CREATE TABLE IF NOT EXISTS fetal_hr (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hr_value REAL,
        timestamp TEXT
    )
''')
con.commit()

###############################################################################
#                            ECG Processing Functions                         #
###############################################################################

def bandpass_filter(data, lowcut, highcut, fs, order=4):
    """
    Applies a Butterworth bandpass filter to 1D NumPy array 'data'.
    """
    nyquist = 0.5 * fs
    low = lowcut / nyquist
    high = highcut / nyquist
    from scipy.signal import butter, filtfilt
    b, a = butter(order, [low, high], btype='band')
    return filtfilt(b, a, data)

def detect_qrs_xqrs(signal_1d, fs):
    """
    Detect QRS complexes using WFDB's XQRS algorithm.
    Returns the indices of detected R-peaks.
    """
    xqrs = XQRS(sig=signal_1d, fs=fs)
    xqrs.detect()  # Default detection
    return xqrs.qrs_inds

def process_ecg(filepath):
    """
    Reads an EDF file, filters & separates ECG signals using ICA, detects
    fetal R-peaks, computes fetal HR, and returns:
      1) A list of fetal HR values (one per RR interval).
      2) A base64-encoded plot of the fetal ECG and detected R-peaks.
    """
    # ------------------ Load EDF ------------------
    f = pyedflib.EdfReader(filepath)
    n_signals = f.signals_in_file
    fs = f.getSampleFrequency(0)  # sampling rate (assumes uniform)
    signals_list = [f.readSignal(i) for i in range(n_signals)]
    f._close()

    # Convert to NumPy array, shape: (samples, channels)
    signals = np.array(signals_list).T

    # ------------------ Filter Signals ------------------
    lowcut = 0.5
    highcut = 40.0
    filtered_signals = np.zeros_like(signals)
    for i in range(signals.shape[1]):
        filtered_signals[:, i] = bandpass_filter(signals[:, i], lowcut, highcut, fs, order=4)

    # ------------------ Apply ICA ------------------
    ica = FastICA(n_components=3, random_state=42)
    S_ = ica.fit_transform(filtered_signals)  # shape: (samples, n_components)

    # ------------------ Identify Fetal Component by HR ------------------
    component_hr = []
    for i in range(S_.shape[1]):
        r_peaks = detect_qrs_xqrs(S_[:, i], fs)
        if len(r_peaks) > 1:
            rr_intervals = np.diff(r_peaks) / fs  # in seconds
            avg_hr = 60.0 / np.mean(rr_intervals)
        else:
            avg_hr = 0
        component_hr.append(avg_hr)

    # Naive selection: pick the component with HR in typical fetal range
    fetal_index = None
    for i, hr in enumerate(component_hr):
        if 110 <= hr <= 180:  # rough fetal HR range
            fetal_index = i
            break

    # ------------------ Compute Fetal HR Series & Plot ------------------
    fetal_hr_series = []
    plot_base64 = None

    if fetal_index is not None:
        fetal_signal = S_[:, fetal_index]
        fetal_r_peaks = detect_qrs_xqrs(fetal_signal, fs)

        if len(fetal_r_peaks) > 1:
            # Fetal RR intervals (s) and instantaneous HR
            fetal_rr_intervals = np.diff(fetal_r_peaks) / fs
            fetal_hr_series = 60.0 / fetal_rr_intervals

        # Create a plot in memory
        fig, ax = plt.subplots(figsize=(12, 4))
        time_axis = np.linspace(0, len(fetal_signal) / fs, len(fetal_signal))
        ax.plot(time_axis, fetal_signal, label='Fetal ECG (ICA Component)')
        ax.plot(fetal_r_peaks/fs, fetal_signal[fetal_r_peaks], 'ro', label='R-peaks')
        ax.set_title('Fetal ECG with Detected R-Peaks')
        ax.set_xlabel('Time (s)')
        ax.set_ylabel('Amplitude')
        ax.legend()

        # Save plot to a bytes buffer
        buf = io.BytesIO()
        plt.tight_layout()
        plt.savefig(buf, format='png')
        plt.close(fig)
        buf.seek(0)

        # Encode plot to base64 so we can embed it in HTML
        plot_base64 = base64.b64encode(buf.getvalue()).decode('utf-8')

    return fetal_hr_series, plot_base64

###############################################################################
#                             Flask Routes                                     #
###############################################################################

@app.route('/', methods=['GET'])
def index():
    """
    Home page with an upload form.
    """
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload():
    """
    Endpoint to receive an EDF file from the sensor (or user).
    Processes it, extracts fetal HR, stores values in DB, and displays results.
    """
    if 'edf_file' not in request.files:
        return "No file part in the request.", 400

    file = request.files['edf_file']
    if file.filename == '':
        return "No file selected.", 400

    # Save the uploaded file
    filepath = os.path.join('uploads', file.filename)
    file.save(filepath)

    # Process the ECG
    fetal_hr_values, plot_base64 = process_ecg(filepath)

    # Store fetal HR values in the database
    for hr_val in fetal_hr_values:
        cur.execute("INSERT INTO fetal_hr (hr_value, timestamp) VALUES (?, ?)", (hr_val, time.ctime()))
    con.commit()

    # Render a page with the results
    return render_template('display.html',
                       image_data=plot_base64,
                       hr_values=fetal_hr_values.tolist() if hasattr(fetal_hr_values, "tolist") else fetal_hr_values)


@app.route('/history', methods=['GET'])
def history():
    """
    Display previously recorded fetal HR values from the database.
    """
    cur.execute("SELECT hr_value, timestamp FROM fetal_hr ORDER BY id DESC LIMIT 50")
    rows = cur.fetchall()
    return render_template('history.html', rows=rows)

if __name__ == '__main__':
    # Run Flask app
    app.run(debug=True)

import random
import smtplib
import sqlite3
import string
import os
import time
import numpy as np
import face_recognition 
from flask import Flask, request, jsonify, send_from_directory, url_for, send_file
from flask_cors import CORS  # Allow Flutter API requests
from werkzeug.utils import secure_filename
import base64
import json
from PIL import Image
import io
import nltk
import vosk
import wave
from nltk.corpus import cmudict
from vosk import Model, KaldiRecognizer
import pronouncing
from collections import defaultdict


wf = wave.open("temp_input.wav", "rb")
model = vosk.Model(r"models\vosk-model-en-in-0.4")  # path to your Vosk model
rec = KaldiRecognizer(model, wf.getframerate())

results = []
while True:
    data = wf.readframes(4000)
    if len(data) == 0:
        break
    if rec.AcceptWaveform(data):
        results.append(json.loads(rec.Result())["text"])

results.append(json.loads(rec.FinalResult())["text"])

print("You said:", " ".join(results))

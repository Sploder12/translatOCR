import sys
def progress(count, total, status=''):
    bar_len = 12
    filled_len = int(round(bar_len * count / float(total)))
    percents = round(100.0 * count / float(total), 1)
    bar = '=' * filled_len + '-' * (bar_len - filled_len)
    sys.stdout.write('[%s] %s%s ...%s\r' % (bar, percents, '%', status))
    sys.stdout.flush()
progress(0, 14, status='Loading Translator')
import os
progress(1, 14, status='Loading Translator')
from pyimagesearch.motion_detection import singlemotiondetector
progress(2, 14, status='Loading Translator')
from imutils.video import VideoStream
progress(3, 14, status='Loading Translator')
from flask import Response, Flask, render_template, request, session, redirect, url_for
progress(4, 14, status='Loading Translator')
from flask_dropzone import Dropzone
progress(5, 14, status='Loading Translator')
from flask_uploads import UploadSet, configure_uploads, IMAGES, patch_request_class
progress(6, 14, status='Loading Translator')
import threading
progress(7, 14, status='Loading Translator')
import argparse
progress(8, 14, status='Loading Translator')
import datetime
progress(9, 14, status='Loading Translator')
import imutils
progress(10, 14, status='Loading Translator')
import time
progress(11, 14, status='Loading Translator')
import cv2
progress(12, 14, status='Loading Translator')
from PIL import Image
progress(13, 14, status='Loading Translator')
from tesserocr import PyTessBaseAPI
progress(14, 14, status='Loading Translator')
print("██╗░░░░░░█████╗░░█████╗░██████╗░██╗███╗░░██╗░██████╗░")
print("██║░░░░░██╔══██╗██╔══██╗██╔══██╗██║████╗░██║██╔════╝░")
print("██║░░░░░██║░░██║███████║██║░░██║██║██╔██╗██║██║░░██╗░")
print("██║░░░░░██║░░██║██╔══██║██║░░██║██║██║╚████║██║░░╚██╗")
print("███████╗╚█████╔╝██║░░██║██████╔╝██║██║░╚███║╚██████╔╝")
print("╚══════╝░╚════╝░╚═╝░░╚═╝╚═════╝░╚═╝╚═╝░░╚══╝░╚═════╝░")

cwd = os.getcwd()
print("Current Directory: " + cwd)

outputFrame = None
lock = threading.Lock()
app = Flask(__name__)
dropzone = Dropzone(app)
vs = VideoStream(src=0).start()
time.sleep(2.0)
sr = cv2.dnn_superres.DnnSuperResImpl_create()

app.config['DROPZONE_UPLOAD_MULTIPLE'] = False
app.config['DROPZONE_ALLOWED_FILE_CUSTOM'] = True
app.config['DROPZONE_ALLOWED_FILE_TYPE'] = 'image/*'
app.config['DROPZONE_REDIRECT_VIEW'] = 'results'
app.config['UPLOADED_PHOTOS_DEST'] = os.getcwd() + '/uploads'
app.config['SECRET_KEY'] = 'supersecretkeygoeshere'

photos = UploadSet('photos', IMAGES)
configure_uploads(app, photos)
patch_request_class(app) 
count = 1

@app.route("/", methods=["GET", "POST"])
def home():
    if request.method == "POST":
        if request.form['button'] == 'Begin video feed':
            return redirect(url_for('streaming'))
        if request.form['button'] == 'Upload Image':
            return redirect(url_for('drop'))
    return render_template("home.html")

@app.route("/streaming", methods=["GET", "POST"])
def streaming():
    global outputFrame, count, url
    if request.method == "POST":
        if request.form['button'] == 'Back':
            return redirect(url_for('home'))
        if "file_url" not in session:
            session['file_url'] = ""
        file_url = session['file_url']
        url = "/static/frame%d.jpg" % count
        height, width, channels = outputFrame.shape
        print(width)
        print(height)
        path = "FSRCNN_x4.pb"
        sr.readModel(path)
        sr.setModel("fsrcnn", 4)
        result = sr.upsample(outputFrame)
        if cv2.imwrite(cwd + "/static/frame%d.jpg" % count, result):
            print("Frame Saved")
        file_url = url
        session['file_url'] = file_url
        count += 1
        return redirect(url_for('capture'))
    return render_template("streaming.html")

@app.route("/capture", methods=["GET", "POST"])
def capture():
    global url
    if request.method == "POST":
        if request.form['button'] == 'Back':
            session['file_url'] = ""
            return redirect(url_for('streaming'))
        with PyTessBaseAPI(path='tessdata') as api:
            api.SetImageFile(cwd + url)
            print(api.GetUTF8Text())
        return redirect(url_for('translated'))
    if "file_url" not in session or session['file_url'] == "":
        return redirect(url_for('streaming'))
    file_url = session['file_url']
    session.pop('file_url', None)
    return render_template("capture.html", file_url=file_url)

@app.route('/drop', methods=['GET', 'POST'])
def drop():
    if "file_urls" not in session:
        session['file_urls'] = []
    file_urls = session['file_urls']
    if request.method == 'POST':
        if request.form['button'] == 'Back':
            return redirect(url_for('home'))
        file_obj = request.files
        for f in file_obj:
            file = request.files.get(f)
            filename = photos.save(file, name=file.filename)
            file_urls.append(photos.url(filename))
            print(file.filename)
        session['file_urls'] = file_urls
        print("\n" + "URL: " + str(file_urls) + "\n")
        return "uploading..."
    return render_template('drop.html')

@app.route('/results', methods=['GET', 'POST'])
def results():
    if "file_urls" not in session or session['file_urls'] == []:
        return redirect(url_for('drop'))
    if request.method == "POST":
        if request.form['button'] == 'Back':
            session['file_urls'] = []
            return redirect(url_for('drop'))
    file_urls = session['file_urls']
    session.pop('file_urls', None)
    return render_template('results.html', file_urls=file_urls)

@app.route('/translated', methods=['GET', 'POST'])
def translated():
    if request.method == 'POST':
        if request.form['button'] == 'Back':
            return redirect(url_for('streaming'))
    return render_template('translated.html')

def detect_motion(frameCount):
    global vs, outputFrame, lock
    md = singlemotiondetector.SingleMotionDetector(accumWeight=0.1)
    total = 0
    while True:
        frame = vs.read()
        frame = imutils.resize(frame)
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        gray = cv2.GaussianBlur(gray, (7, 7), 0)
        timestamp = datetime.datetime.now()
#        cv2.putText(frame, timestamp.strftime(
#            "%A %d %B %Y %I:%M:%S%p"), (10 ,frame.shape[0] - 10),
#            cv2.FONT_HERSHEY_SIMPLEX, 0.35, (0, 0, 255), 1)
        md.update(gray)
        total += 1
        with lock:
            outputFrame = frame.copy()

def generate():
    global outputFrame, lock
    while True:
        with lock:
            if outputFrame is None:
                continue
            (flag, encodedImage) = cv2.imencode(".jpg", outputFrame)
            if not flag:
                continue
        yield(b'--frame\r\n' b'Content-Type: image/jpeg\r\n\r\n' + bytearray(encodedImage) + b'\r\n')

@app.route("/video_feed")
def video_feed():
    return Response(generate(), mimetype = "multipart/x-mixed-replace; boundary=frame")

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ip = input("Enter the IP: ")
    port = int(input("Enter the Port: "))
    ap.add_argument("-f", "--frame-count", type=int, default=32, help="number of frames used to construct the bacground model")
    args = vars(ap.parse_args())
    t = threading.Thread(target=detect_motion, args=(args["frame_count"],))
    t.daemon = True
    t.start()
    x = 0
    while x == 0:
        debug = input("Debug Mode (changes to local only)? (y/n): ")
        if debug == "y" or debug == "n":
            x = 1
        else:
            print("Invalid Response")
    if debug == "y":
        debug = True
    elif debug == "n":
        debug == False
    app.run(host=ip, port=port, debug=debug, threaded=True, use_reloader=False)
vs.stop()
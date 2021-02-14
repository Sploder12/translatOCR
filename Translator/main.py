print("Loading", end="")
from pyimagesearch.motion_detection import singlemotiondetector
print(".", end="")
from imutils.video import VideoStream
print(".", end="")
from flask import Response, Flask, render_template, request, session, redirect, url_for
print(".", end="")
from flask_dropzone import Dropzone
print(".", end="")
from flask_uploads import UploadSet, configure_uploads, IMAGES, patch_request_class
print(".", end="")
import threading
print(".", end="")
import argparse
print(".", end="")
import datetime
print(".", end="")
import imutils
print(".", end="")
import time
print(".", end="")
import cv2
print(".", end="")
import os
print(".")

outputFrame = None
lock = threading.Lock()
app = Flask(__name__)
dropzone = Dropzone(app)
vs = VideoStream(src=0).start()
time.sleep(2.0)

app.config['DROPZONE_UPLOAD_MULTIPLE'] = False
app.config['DROPZONE_ALLOWED_FILE_CUSTOM'] = True
app.config['DROPZONE_ALLOWED_FILE_TYPE'] = 'image/*'
app.config['DROPZONE_REDIRECT_VIEW'] = 'results'
app.config['UPLOADED_PHOTOS_DEST'] = os.getcwd() + 'Translator/uploads'
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
    global outputFrame, count
    if request.method == "POST":
        if "file_url" not in session:
            session['file_url'] = ""
        file_url = session['file_url']
        url = "static/frame%d.jpg" % count
        if cv2.imwrite("Translator/static/frame%d.jpg" % count, outputFrame):
            print("Frame Saved")
        file_url = url
        session['file_url'] = file_url
        count += 1
        return redirect(url_for('capture'))
    return render_template("streaming.html")

@app.route("/capture", methods=["GET", "POST"])
def capture():
    if request.method == "POST":
        #Translate stuff goes here
        if request.form['button'] == 'Back':
            session['file_url'] = ""
            return redirect(url_for('streaming'))
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

@app.route('/results')
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

def detect_motion(frameCount):
    global vs, outputFrame, lock
    md = singlemotiondetector.SingleMotionDetector(accumWeight=0.1)
    total = 0
    while True:
        frame = vs.read()
        frame = imutils.resize(frame, width=400)
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        gray = cv2.GaussianBlur(gray, (7, 7), 0)
        timestamp = datetime.datetime.now()
        cv2.putText(frame, timestamp.strftime(
            "%A %d %B %Y %I:%M:%S%p"), (10 ,frame.shape[0] - 10),
            cv2.FONT_HERSHEY_SIMPLEX, 0.35, (0, 0, 255), 1)
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
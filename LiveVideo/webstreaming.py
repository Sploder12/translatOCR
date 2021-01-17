print("Loading", end="")
from pyimagesearch.motion_detection import singlemotiondetector
print(".", end="")
from imutils.video import VideoStream
print(".", end="")
from flask import Response, Flask, render_template, request, session, redirect, url_for
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
print(".")

outputFrame = None
lock = threading.Lock()
app = Flask(__name__)
vs = VideoStream(src=0).start()
time.sleep(2.0)
app.config['SECRET_KEY'] = 'supersecretkeygoeshere'

ButtonPressed = 0
count = 1
@app.route("/", methods=["GET", "POST"])
def index():
    global outputFrame, count
    if request.method == "POST":
        if "file_urls" not in session:
            session['file_url'] = ""
        file_url = session['file_url']
        url = "static/frame%d.jpg" % count
        if cv2.imwrite("LiveVideo/static/frame%d.jpg" % count, outputFrame):
            print("Frame Saved")
        file_url = url
        session['file_url'] = file_url
        count += 1
        return redirect(url_for('capture'))
        # return render_template("index.html", ButtonPressed = ButtonPressed+1)
    return render_template("index.html", ButtonPressed = ButtonPressed)

@app.route("/capture", methods=["GET", "POST"])
def capture():
    if request.method == "POST":
        translate()
    if "file_url" not in session or session['file_url'] == "":
        return redirect(url_for('index'))
    file_url = session['file_url']
    session.pop('file_url', None)
    return render_template("capture.html", file_url=file_url)

def translate():
    print("The translate button has been pressed")
    # Put something here for translating

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

def generateSingleFrame(imFrame):
    global lock
    with lock:
        if imFrame is None:
            return
        (flag, encodedImage) = cv2.imencode(".jpg", imFrame)
        if not flag:
            return
    yield(b'--frame\r\n' b'Content-Type: image/jpeg\r\n\r\n' + bytearray(encodedImage) + b'\r\n')
    return encodedImage

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
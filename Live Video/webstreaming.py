from pyimagesearch.motion_detection import singlemotiondetector
from imutils.video import VideoStream
from flask import Response, Flask, render_template
import threading
import argparse
import datetime
import imutils
import time
import cv2

outputFrame = None
lock = threading.Lock()
app = Flask(__name__)
vs = VideoStream(src=0).start()
time.sleep(2.0)

@app.route("/")
def index():
    return render_template("index.html")

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
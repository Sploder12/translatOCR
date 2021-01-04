from flask import Flask, render_template, request
from flask_dropzone import Dropzone
from flask_uploads import UploadSet, configure_uploads, IMAGES, patch_request_class
import argparse
import os

app = Flask(__name__)
dropzone = Dropzone(app)

app.config['DROPZONE_UPLOAD_MULTIPLE'] = True
app.config['DROPZONE_ALLOWED_FILE_CUSTOM'] = True
app.config['DROPZONE_ALLOWED_FILE_TYPE'] = 'image/*'
app.config['DROPZONE_REDIRECT_VIEW'] = 'results'
app.config['UPLOADED_PHOTOS_DEST'] = os.getcwd() + '/uploads'

photos = UploadSet('photos', IMAGES)
configure_uploads(app, photos)
patch_request_class(app) 

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/results')
def results():
    return render_template('results.html')

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ip = input("Enter the IP: ")
    port = int(input("Enter the Port: "))
    args = vars(ap.parse_args())
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
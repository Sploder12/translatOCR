print("Loading", end="")
from flask import Flask, render_template, request, redirect, session, url_for
print(".", end="")
from flask_dropzone import Dropzone
print(".", end="")
from flask_uploads import UploadSet, configure_uploads, IMAGES, patch_request_class
print(".", end="")
import argparse
print(".", end="")
import os
print(".")

app = Flask(__name__)
dropzone = Dropzone(app)

app.config['DROPZONE_UPLOAD_MULTIPLE'] = True
app.config['DROPZONE_ALLOWED_FILE_CUSTOM'] = True
app.config['DROPZONE_ALLOWED_FILE_TYPE'] = 'image/*'
app.config['DROPZONE_REDIRECT_VIEW'] = 'results'
app.config['UPLOADED_PHOTOS_DEST'] = os.getcwd() + '/DragAndDrop/uploads'
app.config['SECRET_KEY'] = 'supersecretkeygoeshere'

photos = UploadSet('photos', IMAGES)
configure_uploads(app, photos)
patch_request_class(app) 

@app.route('/', methods=['GET', 'POST'])
def index():
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
    return render_template('index.html')

@app.route('/results')
def results():
    if "file_urls" not in session or session['file_urls'] == []:
        return redirect(url_for('index'))
    file_urls = session['file_urls']
    session.pop('file_urls', None)
    return render_template('results.html', file_urls=file_urls)

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
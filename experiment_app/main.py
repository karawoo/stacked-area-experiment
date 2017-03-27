from flask import Flask, render_template, send_from_directory, request

app = Flask(__name__)
app.debug = True                # Turn on some extra logging

# Show the introductory page first (with info about the study)
@app.route("/")
def intro():
    # Get the path that is passed in from the MTurk request. This contains
    # assignmentId etc., which we need to pass on to the next page in order to
    # capture and return it with the worker's answers.
    path = request.full_path
    # Append /task at the beginning and remove initial / from path
    task_path = "/task" + path[1:]
    return render_template("intro.html", task_path = task_path)

# Serve chart images
@app.route("/charts/<path:path>")
def serve_charts(path):
    return send_from_directory("static/images", path)

# Show a task with a (for now) hard-coded image
@app.route("/task")
def serve_task():
    img = "stacked_area_decreasing_0.825_A.png"
    imgpath = "charts/" + img

    # Get workerId etc. from request
    hit_id = request.args["hitId"]
    assignment_id = request.args["assignmentId"]
    worker_id = request.args["workerId"]
    
    return render_template("task.html", image_url = imgpath, hit_id = hit_id,
                           assignment_id = assignment_id, worker_id = worker_id)

if __name__ == '__main__':
    app.run()
    

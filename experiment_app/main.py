from flask import Flask, render_template, send_from_directory, request
import redis
import os

app = Flask(__name__)
app.debug = True                # Turn on some extra logging

# Redis
db = redis.from_url(os.environ["REDIS_URL"])

# Show the introductory page first (with info about the study)
@app.route("/")
def intro():
    # Get the path that is passed in from the MTurk request. This contains
    # assignmentId etc., which we need to pass on to the next page in order to
    # capture and return it with the worker's answers.
    path = request.full_path
    
    # Create paths for training task and main task. Eventually we'll choose
    # between these based on whether we've seen the user before
    task_path = "/task" + path[1:]
    train_path = "/training" + path[1:]

    # Get worker ID from request args. If worker ID does not exist in Redis,
    # return the training task; otherwise, go to the main task.
    workerId = request.args.get("workerId")
    if not db.get(workerId):
        return render_template("intro.html", path = train_path)
    elif db.get(workerId):
        return render_template("intro.html", path = task_path)

    
# Serve chart images
@app.route("/charts/<path:path>")
def serve_charts(path):
    return send_from_directory("static/images", path)


# Extract MTurk variables
def get_ids():
    # Try to get them from the request args
    hit_id = request.args.get("hitId")
    assignment_id = request.args.get("assignmentId")
    worker_id = request.args.get("workerId")
    train = request.args.get("train")
    task = request.args.get("task")

    # If that didn't work (i.e. because there were no args), get them from the
    # training task form data
    if not any([hit_id, assignment_id, worker_id]):
            hit_id = request.form.get("hitId")
            assignment_id = request.form.get("assignmentId")
            worker_id = request.form.get("workerId")
            train = request.form.get("train")
            task = request.form.get("task")

    # If there are still no values, throw an error
    if not any([hit_id, assignment_id, worker_id, train, task]):
        raise ValueError("Could not find hitId, assignmentId, workerId, training images, or task images")
    
    return hit_id, assignment_id, worker_id, train, task

     
# Show training task
@app.route("/training")
def serve_training():
    # Get workerId etc. from request
    hit_id, assignment_id, worker_id, train_imgpath, task_imgpath = get_ids()

    return render_template("training.html", train_image_url = train_imgpath,
                           hit_id = hit_id, assignment_id = assignment_id,
                           worker_id = worker_id, task_image_url = task_imgpath)


# Show a task with a (for now) hard-coded image
@app.route("/task", methods = ["POST", "GET"])
def serve_task():
    # Get the training task data, or set to empty strings if there is no form
    # (i.e. no training task)
    Q1 = request.form.get("Q1", "")
    Q2 = request.form.get("Q2", "")
    Q3 = request.form.get("Q3", "")

    # Get MTurk variables
    hit_id, assignment_id, worker_id, train_imgpath, task_imgpath  = get_ids()

    # Save worker ID to Redis -- right now this will save as soon as the person
    # opens this page, it does NOT wait until they have submitted the task
    db.set(worker_id, worker_id)
    
    return render_template("task.html", task_image_url = task_imgpath, Q1 = Q1, Q2 = Q2,
                           Q3 = Q3, hit_id = hit_id, assignment_id =
                           assignment_id, worker_id = worker_id)


if __name__ == '__main__':
    app.run()
    

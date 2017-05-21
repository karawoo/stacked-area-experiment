# Stacked Area Graphical Perception Experiment

This repo contains an experiment to test viewers' perception of stacked area
charts. Currently written as a Flask app, the experiment shows information about
the study (including contact information), then takes viewers to a page where
they are presented with a chart and are asked to answer a few questions about
it.

[`chart_generator.R`](chart_generator.R) is the file that creates the chart
images.

The [`experiment_app/`](experiment_app/) folder has the code for the experiment
itself.

Currently the app is running at https://salty-shore-16410.herokuapp.com.
However, to progress beyond the first page you need a URL like
https://salty-shore-16410.herokuapp.com/?train=charts/stacked_area_TEST_3.png&task=charts/stacked_area_decreasing_0.825_A.png&assignmentId=67483929810ASLDKFJ929&workerId=295JS1LSDKFJSQ&hitId=123RVWYBAZW00EXAMPLE.
These parameters get sent on to the next page so that they can be returned along
with the workers' results.


## Running locally:

Start a redis instance at the command line 

```
redis-server
```

Comment out the following line from `experiment_app/main.py`:

```
db = redis.from_url(os.environ["REDIS_URL"])
```

And replace it with:

```
db = redis.StrictRedis(host='localhost', port=6379, db=0)
```

This will create a local redis instance and connect to it rather than trying to connect to the instance on Heroku.

Then run the app:

```
python experiment_app/main.py
```

And view it at
localhost:5000/?train=charts/stacked_area_TEST_3.png&task=charts/stacked_area_decreasing_0.825_A.png&assignmentId=12345&workerId=12345&hitId=12345.
You can replace the `train` and `task` images with any others from
`experiment_app/static/images`, and the `assignmentId`, `workerId`, and `hitId`
parameters can be anything.

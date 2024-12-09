FROM python:3.11-alpine3.20
RUN mkdir /app/
WORKDIR /app/

COPY ./src/requirements.txt /app/requirements.txt

RUN pip install --upgrade pip
RUN pip install -r /app/requirements.txt

COPY ./src/ /app/

ENV FLASK_APP=app.py
ENV FLASK_DEBUG=1
ENV PYTHONUNBUFFERED=1

CMD ["sh", "-c", "python3 -m flask run --host=0.0.0.0 --port=${NEO4J_METRICS_PORT}"]

# CMD ["sh", "-c", "gunicorn -w 1 -b 0.0.0.0:$NEO4J_METRICS_PORT app:app"]

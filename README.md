kyle notes:

docker-compose up --build
docker exec -it my_postgres bash (?)
docker-compose down to remove volumes
docker exec -it postgres psql -d fishsense_db -U placeholder_superuser
run env too






made env

pip install psycog2

future dockerfile:
# Step 1: Use an official Python runtime as the base image
FROM python:3.9-slim

# Step 2: Set the working directory in the container
WORKDIR /app

# Step 3: Copy the requirements.txt file to install dependencies
COPY requirements.txt .

# Step 4: Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Step 5: Copy the rest of your application code into the container
COPY . .

# Step 6: Set environment variables (optional, could be handled by Docker Compose)
ENV PYTHONUNBUFFERED=1

# Step 7: Run the application (adjust this based on your app's entry point)
CMD ["python", "app.py"]



do backend services to create routes to be able to interface with database

keep sqlite database in fishsense lite jic headless system has no wifi, then when internet, then initiate transfer to postgresql

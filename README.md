# RescuePulse

**A Fully Working Project built for the WSO2 Ballerina Hackathon 2025**

This project, developed by Dineth basura with team innovaters (this is Dineth's Part others parts included originsl repository in description link ), is an innovative application designed to enhance emergency response and management through AI-powered risk prediction and a comprehensive web interface. RescuePulse aims to provide a robust platform for predicting potential emergencies, alerting relevant personnel, and managing critical data efficiently.

## Table of Contents

- [Features](#features)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Setup Guide](#setup-guide)
  - [Prerequisites](#prerequisites)
  - [Getting Started with Docker Compose](#getting-started-with-docker-compose)
  - [Running Components Individually](#running-components-individually)
    - [Backend (Ballerina)](#backend-ballerina)
    - [AI Service (Python)](#ai-service-python)
    - [Frontend (Web)](#frontend-web)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Features

*   **AI-Powered Risk Prediction**: Utilizes machine learning models to predict potential emergency situations based on various data inputs.
*   **Real-time Alerting**: Notifies emergency services and relevant stakeholders about predicted risks and ongoing incidents.
*   **User and Admin Dashboards**: Provides intuitive web interfaces for users to monitor their status and for administrators to manage the system, view alerts, and configure settings.
*   **Secure Authentication**: Manages user access and ensures data security through robust authentication mechanisms.
*   **Data Management**: Handles critical data related to emergencies, users, and system operations.
*   **Containerized Deployment**: Easily deployable using Docker for consistent environments.

## Technologies Used

*   **Backend**: Ballerina (for services like AI integration, alerts, authentication, data, and web handling).
*   **AI/Machine Learning**: Python (for model training and prediction).
*   **Frontend**: HTML, CSS, JavaScript (for the user interface).
*   **Database**: (Implicit, likely integrated via Ballerina data services, specific technology not explicitly listed in file structure but assumed for data persistence).
*   **Containerization**: Docker, Docker Compose.

## Project Structure

The project is organized into several key directories:

```
RescuePulse/
├── ai/
│   ├── models/
│   │   └── risk_model.pkl
│   ├── data/
│   │   └── sample_data.csv
│   ├── train_model.py
│   └── predict.py
├── backend/
│   ├── src/
│   │   ├── ai_service.bal
│   │   ├── alert_service.bal
│   │   ├── auth_service.bal
│   │   ├── data_service.bal
│   │   ├── http_listener.bal
│   │   └── web_service.bal
│   └── target/
│       ├── bin/
│       ├── cache/
│       ├── resources/
│       └── build/
├── frontend/
│   ├── assets/
│   │   └── logo.png
│   ├── index.html
│   ├── sign-in.html
│   ├── sign-up.html
│   ├── user-dashboard.html
│   ├── admin-dashboard.html
│   ├── docs.html
│   ├── aboutus.html
│   ├── styles.css
│   └── script.js
├── docs/
│   ├── architecture.md
│   ├── impact_report.md
│   └── setup_guide.md
├── vs code/
│   ├── launch.json
│   ├── settings.json
│   └── .dockerignore
├── compose.yaml
├── compose.debug.yaml
├── Dockerfile
├── requirements.txt
├── LICENSE
└── README.md
```

## Setup Guide

### Prerequisites

Before you begin, ensure you have the following installed:

*   [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/)
*   [Ballerina](https://ballerina.io/downloads/)
*   [Python 3.x](https://www.python.org/downloads/) and `pip`

### Getting Started with Docker Compose

The easiest way to get RescuePulse up and running is by using Docker Compose:

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/Dineth-Basura/RescuePulse-WSO2_BallerinaHackathon2025.git
    cd RescuePulse-WSO2_BallerinaHackathon2025
    ```

2.  **Build and run the services**:
    ```bash
    docker-compose up --build
    ```
    This command will build the Docker images for the backend and AI services, and then start all defined services.

3.  **Access the application**:
    Once the services are up, you can access the frontend web application in your browser, typically at `http://localhost:8080`.

### Running Components Individually

#### Backend (Ballerina)

1.  **Install Ballerina**: Follow the instructions on the [Ballerina website](https://ballerina.io/downloads/).
2.  **Navigate to the backend directory**:
    ```bash
    cd backend/src
    ```
3.  **Build the Ballerina project**:
    ```bash
    bal build
    ```
4.  **Run the backend service**:
    ```bash
    bal run
    ```
    The backend service will start, usually listening on port 9090.

#### AI Service (Python)

1.  **Install Python dependencies**:
    ```bash
    pip install -r requirements.txt
    ```
2.  **Navigate to the AI directory**:
    ```bash
    cd ai
    ```
3.  **Run the prediction service (example)**:
    ```bash
    python predict.py
    ```
    *Note: You might need to train the model first using `python train_model.py` if `risk_model.pkl` is not present or needs updating.*

#### Frontend (Web)

The frontend is a collection of static HTML, CSS, and JavaScript files. You can serve them using any static file server or simply open `frontend/index.html` directly in your browser.

1.  **Navigate to the frontend directory**:
    ```bash
    cd frontend
    ```
2.  **Open `index.html` in your browser**:
    You can typically do this by dragging the `index.html` file into your browser, or by using a local web server (e.g., `python -m http.server` if you have Python installed).

## Usage

*   **Sign Up/Sign In**: Navigate to `sign-up.html` or `sign-in.html` to create an account or log in.
*   **User Dashboard**: After logging in, users can access `user-dashboard.html` to view relevant information and alerts.
*   **Admin Dashboard**: Administrators can access `admin-dashboard.html` for system management and oversight.
*   **Documentation**: `docs.html` (if implemented) would provide in-app documentation.

## Contributing

We welcome contributions to RescuePulse! Please refer to the `CONTRIBUTING.md` (if available) for guidelines on how to contribute.

## License

This project is licensed under the terms of the [LICENSE](LICENSE) file.
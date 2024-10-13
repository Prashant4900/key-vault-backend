# Key Vault

## Overview

This project is a RESTful API built using [Dart Frog](https://dartfrog.vgv.dev), designed to handle user authentication, secret key management, and logging. The API supports operations such as user login, adding and retrieving secret keys, and managing logs, making it suitable for applications requiring secure data handling.

## Features

- **User Authentication**: Securely login users and manage tokens.
- **Secret Key Management**: Add and retrieve secret keys securely.
- **Logging**: Log user activity and manage logs.

## Getting Started

### Prerequisites

- Dart SDK (>=2.12.0)
- Dart Frog (installed via `dart pub global activate dart_frog`)
- An HTTP client library (e.g., `http` package)
- dotenv package for environment variables

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/key_vault.git
   cd key_vault
   ```

2.	Install the dependencies:

    ```bash
    dart pub get
    ```

3.	Create a .env file in the root directory and add your environment variables:

    ```bash
    BASE_URL=<your_base_url>
    SUPABASE_ANON=<your_supabase_anon_key>
    ```

## Running the Project

To run the server, execute the following command:

```bash
dart_frog dev
```

The API will be available at http://localhost:8080.

### API Endpoints

| Method | Endpoint            | Description                                  |
|--------|---------------------|----------------------------------------------|
| POST   | `/api/auth/login`   | Authenticates a user and returns a token.   |
| POST   | `/api/secret/add`   | Adds a new secret key.                       |
| GET    | `/api/secret/get`   | Retrieves a secret key by its associated key.|
| POST   | `/api/logs/add`     | Adds a new log entry.                        |
| GET    | `/api/logs/get`     | Retrieves logs.                              |
| GET    | `/api/logs/`        | Returns a message indicating the logs API.  |
| GET    | `/api/secret/`      | Returns a message indicating the secret API. |

## Example Request

### User Login

```bash
curl -X POST http://localhost:8080/api/auth/login \
-H "Content-Type: application/json" \
-d '{"email": "user@example.com", "password": "yourpassword"}'
```

## Contributing

Contributions are welcome! If you would like to contribute to this project, please follow these steps:

1.	Fork the repository.
2.	Create your feature branch (git checkout -b feature/YourFeature).
3.	Commit your changes (git commit -m 'Add some feature').
4.	Push to the branch (git push origin feature/YourFeature).
5.	Open a pull request.

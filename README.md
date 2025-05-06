# Linga chatbot application


##  Talkie Tool – AI-Powered English Chatbot App

Talkie Tool is a Flutter-based mobile app that helps users improve their English skills and interview readiness. It features an AI chatbot with grammar correction, speech-to-text voice input, grammar scoring, and user account support (sign-up, login, and profile management).

---

###  Features

*  AI-powered chatbot with **Basic** and **Pro** modes
*  Voice-to-text input and **AI voice response** (planned)
*  Grammar corrections and score feedback
*  Chat history display (conversation threads)
*  Secure login/signup with JWT
*  Theme switch support (light/dark)
*  Guest mode access (limited features)

---

###  Screens Overview

* **HomeScreen**

  * Text and voice chat interface
  * Mode toggle: Basic ↔ Pro
  * Drawer with “New Chat” option
  * Conditional UI for logged-in vs guest users

* **VoiceChatScreen**

  * Record voice input
  * Display transcription and AI responses
  * Placeholder AI audio reply (voice output in future)

* **Login & Signup Screens**

  * User authentication using JWT
  * Animated transitions

* **ProfileModal**

  * Displays user details
  * Theme toggle and logout

---

###  Getting Started

#### 1. Clone the Repository

```bash
git clone 
cd talkie-tool
```

#### 2. Install Dependencies

```bash
flutter pub get
```

#### 3. Run the App

```bash
flutter run
```

---

### 📦 Dependencies

```yaml
dependencies:
  flutter:
  http:
  flutter_secure_storage:
  speech_to_text:
  flutter_tts:
```

> Add more dependencies if you're using additional plugins like animations, themes, or packages like `provider`.

---

###  API & Backend

* API Base URL: `https://englishbot-devs.onrender.com`
* Auth API: Login, Signup, Get user details
* Chat API: Send/receive messages with grammar corrections

> Auth APIs are handled in `auth_api.dart`.

---

### 🔐 Token Handling

* Token saved using `flutter_secure_storage`
* Auto-fetch user data on app launch if token exists
* Full logout flow: clear token + reset state

---

### 📂 Folder Structure (Simplified)

```
lib/
├── api/              # Auth API calls
├── screens/          # Home, VoiceChat, Login, Signup
├── widgets/          # Chat UI elements, Profile modal
├── main.dart         # App entry point
```

---

###  Coming Soon

*  AI-generated voice responses
*  Save/load previous chat threads
*  Performance analytics (grammar progress)

---

###  License

MIT License – feel free to use and modify!

---

This is the backend for the Linguabot conversational AI application. It provides APIs for managing conversations, messages, and user authentication. The backend is built using FastAPI and integrates with a database (e.g., MongoDB) for storing conversations and messages.

---

## **Table of Contents**
- [Features](#features)
- [API Endpoints](#api-endpoints)
  - [Conversations](#conversations)
  - [Messages](#messages)
  - [Authentication](#authentication)
- [Request and Response Examples](#request-and-response-examples)
- [Setup and Installation](#setup-and-installation)

---

## **Features**
- Create, retrieve, and delete conversations.
- Add and retrieve messages in a conversation.
- JWT-based authentication for secure access.
- Integration with Gemini AI for generating bot replies.

---

## **API Endpoints**

### **Conversations**
#### 1. **Create a Conversation**
- **Endpoint**: `POST /conversation/`
- **Description**: Creates a new conversation.
- **Input**:
  ```json
  {
    "title": "Chat with AI",
    "description": "A conversation with the AI bot",
    "image": "https://example.com/image.png"
  }
  ```
- **Output**:
  ```json
  {
    "id": "680458b3324cd9ea63434145",
    "title": "Chat with AI",
    "description": "A conversation with the AI bot",
    "image": "https://example.com/image.png",
    "user_id": "12345",
    "created_at": "2025-04-25T12:00:00Z",
    "last_message_at": null
  }
  ```

#### 2. **Get All Conversations for a User**
- **Endpoint**: `GET /conversation/`
- **Description**: Retrieves all conversations for the authenticated user.
- **Input**: JWT token in the `Authorization` header.
- **Output**:
  ```json
  [
    {
      "id": "680458b3324cd9ea63434145",
      "title": "Chat with AI",
      "description": "A conversation with the AI bot",
      "image": "https://example.com/image.png",
      "user_id": "12345",
      "created_at": "2025-04-25T12:00:00Z",
      "last_message_at": "2025-04-25T12:30:00Z"
    }
  ]
  ```

#### 3. **Delete a Conversation**
- **Endpoint**: `DELETE /conversation/{conversation_id}`
- **Description**: Deletes a conversation by its ID.
- **Input**: 
  - Path parameter: `conversation_id` (string)
  - JWT token in the `Authorization` header.
- **Output**:
  ```json
  {
    "detail": "Conversation deleted successfully"
  }
  ```

---

### **Messages**
#### 1. **Add a Message**
- **Endpoint**: `POST /message/{conversation_id}/message`
- **Description**: Adds a message to a conversation and generates a bot reply.
- **Input**:
  - Path parameter: `conversation_id` (string)
  - Request body:
    ```json
    {
      "content": "Hello, AI!",
      "sender_id": "user"
    }
    ```
- **Output**:
  ```json
  {
    "id": "680458b3324cd9ea63434146",
    "content": "Hello, AI!",
    "sender_id": "user",
    "conversation_id": "680458b3324cd9ea63434145",
    "timestamp": "2025-04-25T12:30:00Z",
    "reply_to": null
  }
  ```

#### 2. **Get Conversation History**
- **Endpoint**: `GET /message/{conversation_id}/history`
- **Description**: Retrieves the message history for a conversation.
- **Input**:
  - Path parameter: `conversation_id` (string)
  - Query parameters:
    - `limit` (integer, optional): Number of messages to retrieve (default: 20).
    - `offset` (integer, optional): Number of messages to skip (default: 0).
- **Output**:
  ```json
  [
    {
      "id": "680458b3324cd9ea63434146",
      "content": "Hello, AI!",
      "sender_id": "user",
      "conversation_id": "680458b3324cd9ea63434145",
      "timestamp": "2025-04-25T12:30:00Z",
      "reply_to": null
    },
    {
      "id": "680458b3324cd9ea63434147",
      "content": "Hello! How can I assist you today?",
      "sender_id": "bot",
      "conversation_id": "680458b3324cd9ea63434145",
      "timestamp": "2025-04-25T12:30:05Z",
      "reply_to": "680458b3324cd9ea63434146"
    }
  ]
  ```

---

### **Authentication**
#### 1. **Login**
- **Endpoint**: `POST /auth/login`
- **Description**: Authenticates a user and returns a JWT token.
- **Input**:
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```
- **Output**:
  ```json
  {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer"
  }
  ```

#### 2. **Get Current User**
- **Endpoint**: `GET /auth/user`
- **Description**: Retrieves the details of the authenticated user.
- **Input**: JWT token in the `Authorization` header.
- **Output**:
  ```json
  {
    "id": "12345",
    "email": "user@example.com",
    "username": "JohnDoe"
  }
  ```

---

## **Request and Response Examples**

### **Authorization Header**
All protected routes require the `Authorization` header with the JWT token:
```
Authorization: Bearer <your_token>
```

---

## **Setup and Installation**

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/linguabot-backend.git
   cd linguabot-backend
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Set up environment variables:
   - Create a `.env` file in the root directory.
   - Add the following variables:
     ```
     SECRET_KEY=your_secret_key
     ALGORITHM=HS256
     GEMINI_API_KEY=your_gemini_api_key
     ```

4. Run the application:
   ```bash
   uvicorn main:app --reload
   ```

5. Access the API documentation:
   - Open your browser and go to `http://127.0.0.1:8000/docs`.

---

## **Contributing**
Feel free to submit issues or pull requests to improve this project.

---

## **License**
This project is licensed under the MIT License.



this is the backend for model used in this project
metadata
library_name: transformers
tags:
  - grammar-correction
  - t5
  - text-to-text
  - english
license: apache-2.0
datasets:
  - chaojiang06/wiki_auto
language:
  - en
base_model:
  - google-t5/t5-small
pipeline_tag: text2text-generation
T5-Small Grammar Correction
A fine-tuned t5-small model for correcting grammar errors in English text. Given a sentence, the model generates a grammatically correct version using a text-to-text approach.

Model Details
Developed by: Harsha Vardhan N
Model type: Sequence-to-Sequence Transformer
Language(s): English
License: Apache 2.0
Finetuned from model: t5-small
Training Details
Training Data
The model was fine-tuned on the wiki_auto/auto_full_with_split dataset, a large-scale corpus designed for sentence-level grammatical and stylistic simplification. It contains aligned pairs of complex and simplified English sentences extracted from Wikipedia and Simple Wikipedia. For this task, the dataset was used to teach the model how to correct ungrammatical sentences into fluent and grammatically correct English.

Training Procedure
Epochs: 3
Training Duration: ~1 hour
Optimizer: AdamW (via Hugging Face Seq2SeqTrainer)
Learning Rate: 5e-5
Batch Size: 8
Environment: Google Colab GPU
Technical Specifications
Compute Infrastructure
Hardware
GPU: Google Colab-provided GPU (likely Tesla T4)
Software
Framework: Hugging Face Transformers, PyTorch
Trainer Used: Seq2SeqTraine

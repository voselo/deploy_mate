# **Deploy Mate**

🚀 Deploy Mate is a CI/CD utility designed to simplify and automate the build and deployment process for Flutter applications. It supports multiple flavors, build types, and deployment to services.

---

## **Features**
- Multi-flavor builds (APK, AAB, IPA)
- Automatic build number increment
- Deployment integrations (Appstore Connect, Yandex Drive)
- Telegram build reports
- CI/CD-ready configuration with automated setup for tokens

---

## **Requirements**
### **General:**
- **Flutter SDK** installed and available in your PATH
- **Dart SDK**.
- CI/CD environment with access to environment variables

### **Yandex Disk Requirements:**
- A Yandex OAuth API app configured as described in the **Setup** section

### **Telegram Bot Setup:**
- A bot token
- A chat ID (for a group, channel, or direct messages)

---

## **Setup**

### **1. Configure Telegram Bot**
1. Create a bot via [BotFather](https://t.me/botfather)
2. Obtain the **bot token**
3. Add your bot to a channel or group and make it an admin (if necessary)
4. Obtain the **chat ID**:
   - Start a conversation with your bot and use `/start`.
   - Retrieve the ID with an API request:  
     `https://api.telegram.org/bot<YourBOTToken>/getUpdates`.t

### **2. Yandex OAuth API Application**
1. Go to [Yandex Developer Console](https://oauth.yandex.ru/client/new).
2. Configure your application as follows:
   - **Platform**: Select `Web-сервис`.
   - **Redirect URI**: `http://localhost:8080/callback`.
   - **Access Permissions**:
     - `Запись в любом месте на Диске (cloud_api:disk.write)`
     - `Чтение всего Диска (cloud_api:disk.read)`
     - `Доступ к информации о Диске (cloud_api:disk.info)`
   - Save your app to generate the `client_id` and `client_secret`.

### **3. Configure `build_config.yaml`**
Set up the following in your `build_config.yaml`:
```yaml
bot_token: 'your-telegram-bot-token'
chat_id: 'your-telegram-chat-id'
yandex_app_client_id: 'dae3ab6b701e4b56bd83e52dbcf210d1'
yandex_app_client_secret: '637168ea320745c485bb7254f98316b4'
yandex_token: '' # Leave empty for the first run
```

## **Installation**

1. **Clone the repository:**
  
2. **Compile the executable:**
   ```bash
   dart compile exe bin/builder.dart -o dmate

3 **Move the executable to your PATH:**
   - macOS/Linux:
        ```bash
        sudo mv dmate /usr/local/bin/ 
       
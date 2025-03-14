# 🌉 Bridge Monitor – Παρακολούθηση Γεφυρών Ισθμίας & Ποσειδωνίας

Αυτό το project παρέχει έναν αυτοματοποιημένο και αξιόπιστο τρόπο παρακολούθησης της κατάστασης των γεφυρών του Ισθμού της Κορίνθου (Ποσειδωνία & Ισθμία). Λαμβάνετε άμεσες ειδοποιήσεις στο κινητό σας μέσω της εφαρμογής Pushover όταν οι γέφυρες είναι κλειστές ή ανοιχτές.

---

## 🚀 Πώς λειτουργεί;

Το Docker container εκτελεί συνεχώς ένα PowerShell script το οποίο:

- Ελέγχει κάθε 5 λεπτά την κατάσταση των γεφυρών.
- Ανιχνεύει αλλαγές και στέλνει ειδοποιήσεις push στο κινητό.
- Σε περίπτωση που κάποια γέφυρα είναι κλειστή, ανακτά μέσω OCR πληροφορίες από εικόνες χρησιμοποιώντας το Google Vision API.

---

## 🛠 Προαπαιτήσεις

- Docker
- Google Vision API Key
- Pushover API Key
- Pushover User Key
- Εφαρμογή Pushover στο κινητό (Android/iOS)

---

## 🔑 Ρύθμιση & Εγκατάσταση

### 1. Δημιουργία API Keys

#### Google Vision API
```
1. Μεταβείτε στο https://console.cloud.google.com/.
2. Δημιουργήστε ή επιλέξτε ένα project.
3. Ενεργοποιήστε το Cloud Vision API.
4. Δημιουργήστε ένα API Key από Credentials → Create Credentials → API Key.
```

#### Pushover
```
1. Μεταβείτε στο https://pushover.net.
2. Σημειώστε το User Key σας (διαθέσιμο στο Dashboard).
3. Δημιουργήστε ένα νέο API Key επιλέγοντας Create an Application/API Token στην ενότητα Your Applications.
```

### 2. Δημιουργία αρχείου με Secrets
```
Δημιουργήστε αρχείο με το όνομα mysecret και το παρακάτω περιεχόμενο:

API_KEY=your_google_vision_api_key
POAPI_KEY=your_pushover_api_key
POUSER_KEY=your_pushover_user_key
```

### 3. Δημιουργία Docker Image
```
docker build --secret id=mysecret,src=mysecret -t bridge-monitor .
```

### 4. Εκτέλεση Container
```
docker run -d --name bridge-monitor-container bridge-monitor
```

---

## 📂 Περιεχόμενα Repository
```
- Dockerfile – Δημιουργία του Docker container.
- script.ps1 – Το PowerShell script που εκτελεί τον έλεγχο.
- image_sources.csv – Καταγραφή της κατάστασης των γεφυρών.
```

---
## 📲 Eγκατάσταση εφαρμογής Pushover στο κινητό

Εγκαταστήστε την εφαρμογή Pushover για κινητά:
- [Android](https://play.google.com/store/apps/details?id=net.superblock.pushover)
- [iOS](https://apps.apple.com/us/app/pushover-notifications/id506088175)

---

## 📲 Παράδειγμα Ειδοποίησης
```
Γέφυρα Ισθμίας είναι κλειστή! Ανοίγει στις 17:15 (σε 25 λεπτά). Κλειστή για 30 λεπτά. Καλύτερα να μη περιμένεις!
```

---

## 🤝 Συνεισφορά

Κάθε συνεισφορά είναι ευπρόσδεκτη! Μη διστάσετε να ανοίξετε ένα issue ή να υποβάλετε ένα pull request.

---

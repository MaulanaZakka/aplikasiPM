import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:image_picker/image_picker.dart";
import 'package:path/path.dart' as path;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:appwrite/appwrite.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationService.initialize();


  final messagesController = Get.put(MessagesController());
  messagesController.fetchMessages();

  // Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Get.putAsync(() async => await SharedPreferences.getInstance());
  await FirebaseMessagingHandler().initPushNotification();

  final client = Client();

  client
      .setEndpoint('https://cloud.appwrite.io/v1') // Your Appwrite Endpoint
      .setProject('65605956add14b7ea35b') // Your project ID
      ;

  final imageController = Get.put(ImageController(client: client));
  imageController.loadSavedImage();
  runApp(const MyApp());
}


//Model
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Message received in background: ${message.notification?.title}');
}
class FirebaseMessagingHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel(
      'channel_notification',
      'High Importance Notification',
      description: 'Used For Notification',
      importance: Importance.defaultImportance,
  );
  final _localNotification = FlutterLocalNotificationsPlugin();
      Future<void> initPushNotification() async {
//allow user to give permission for notification
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
//get token messaging
    _firebaseMessaging.getToken().then((token) {
      print('FCM Token: $token');
    });
//handler terminated message
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      print("terminatedNotification : ${message!.notification?.title}");
    });
//handler onbackground message
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        //handler foreground message with local notification
        FirebaseMessaging.onMessage.listen((message) {
          final notification = message.notification;
          if (notification == null) return;
          _localNotification.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(
                    _androidChannel.id, _androidChannel.name,
                    channelDescription: _androidChannel.description,
                    icon: '@drawable/ic_launcher')),
            payload: jsonEncode(message.toMap()),
          );
          print(
              'Message received while app is in foreground: ${message.notification?.title}');
        });
//handler when open the message
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print('Message opened from notification: ${message.notification?.title}');
        });
      }
  Future initLocalNotification() async {
    const ios = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: ios);
    await _localNotification.initialize(settings);
  }
  void showLocalNotification({required String title, required String body}) {
    _localNotification.show(
      4229429663246734900,  // ID notifikasi
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: '@drawable/ic_launcher',
        ),
      ),
    );
  }
}

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initialize() {
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'));

    _notificationsPlugin.initialize(initializationSettings);
  }

  static Future singleNotification(
      {required String title, required String body, required int id}) async {
    AndroidNotificationDetails androidChannelSpecifics = AndroidNotificationDetails(
      'message_channel',
      'Message Channel',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: true,
    );

    NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

class Message {
  final String content;

  Message({required this.content});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['files']['JKT48_LastPM.md']['content'],
    );
  }
}



//View
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildContainerWithText('Apa itu JKT48 Private Message?',
              'aplikasi berasa dapat chat dari oshi'),
          const SizedBox(height: 35),
          const Text(
            'TOP 5 MEMBERS',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          buildContainerWithText('TOP 1','Zee'),
          const SizedBox(height: 5),
          buildContainerWithText('TOP 2','Christy'),
          const SizedBox(height: 5),
          buildContainerWithText('TOP 3','Cynthia'),
          const SizedBox(height: 5),
          buildContainerWithText('TOP 4','Indah'),
          const SizedBox(height: 5),
          buildContainerWithText('TOP 5','Lia'),
        ],
      ),
    );
  }
}
class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          buildContainerWithText('Paket 1 Member','Rp40.000,00 / Bulan'),
          const SizedBox(height:10),
          buildContainerWithText('Paket 3 Member','Rp90.000,00 / Bulan'),
          const SizedBox(height:10),
          buildContainerWithText('Paket 5 Member','Rp139.000,00 / Bulan'),
          const SizedBox(height:10),
          buildContainerWithText('Paket 7 Member','Rp179.000,00 / Bulan'),
          const SizedBox(height:10),
          buildContainerWithText('Paket All Member','Rp590.000,00 / Bulan'),
        ],
      ),
    );
  }
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessagesController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Last PM'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Tampilkan notifikasi lokal di sini
              FirebaseMessagingHandler().showLocalNotification(
                title: 'Reload',
                body: 'Halaman sedang dimuat ulang',
              );
              controller.fetchMessages();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(
                  () => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.messages.value.content.isNotEmpty
                  ? Text(controller.messages.value.content)
                  : const Center(child: Text('No data')),
            ),
            ElevatedButton(
              onPressed: () {
                // Tampilkan notifikasi lokal di sini
                FirebaseMessagingHandler().showLocalNotification(
                  title: 'Navigasi',
                  body: 'Anda akan dialihkan ke halaman web JKT48',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WebViewPage()),
                );
              },
              child: Text('JKT48'),
            ),
          ],
        ),
      ),
    );
  }
}
class WebViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JKT48'),
      ),
      body: WebView(
        initialUrl: 'https://jkt48.com',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final AuthController _authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _authController.signInWithEmailAndPassword(
                      _emailController.text,
                      _passwordController.text,
                    ).then((credential) {
                      if (credential != null) {
                        // Jika berhasil masuk, arahkan pengguna ke halaman utama
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                      }
                    });
                  }
                },
                child: const Text('Sign In with Email'),
              ),

              ElevatedButton(
                onPressed: () {
                  _authController.signInWithGoogle();
                },
                child: const Text('Sign In with Google'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: const Text('Create Account'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
class RegisterPage extends StatelessWidget {
  final AuthController _authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _authController.registerWithEmailAndPassword(
                      _emailController.text,
                      _passwordController.text,
                    ).then((_) {
                      Navigator.pop(context); // kembali ke halaman login
                    });
                  }
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Profile
class UserController extends GetxController {
  var name = ''.obs;
  var email = ''.obs;
  var phoneNumber = ''.obs;

  final Client client = Client();
  late final Databases database;

  Future listAllDocuments(String collectionId) async {
    return await database.listDocuments(
      databaseId: 'pm',
      collectionId: 'data123',
    );
  }

  UserController() {
    client
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('65605956add14b7ea35b');
    database = Databases(client);
  }
  // Create
  Future createData(String collectionId) async {
    await database.createDocument(
      documentId: ID.unique(),
      databaseId: 'pm',
      collectionId: 'data123',
      data: {
        'name': name.value,
        'email': email.value,
        'phoneNumber': phoneNumber.value,
      },
    );
  }

  // Read
  Future readData(String collectionId, String documentId) async {
    var response = await database.getDocument(
      databaseId: 'pm',
      collectionId: 'data123',
      documentId: ID.unique(),
    );
    var data = response.data;
    print('Name: ${data['name']}');
    print('Email: ${data['email']}');
    print('Phone Number: ${data['phoneNumber']}');
  }

  // Update
  void updateData(String newName, String newEmail, String newPhoneNumber) {
    name.value = newName;
    email.value = newEmail;
    phoneNumber.value = newPhoneNumber;
  }

  Future updateDataInDatabase(String collectionId, String documentId) async {
    await database.updateDocument(
      databaseId: 'pm',
      collectionId: 'data123',
      documentId: ID.unique(),
      data: {
        'name': name.value,
        'email': email.value,
        'phoneNumber': phoneNumber.value,
      },
    );
  }
  // Delete
  void deleteData() {
    name.value = '';
    email.value = '';
    phoneNumber.value = '';
  }
  Future deleteDataFromDatabase(String collectionId, String documentId) async {
    await database.deleteDocument(
      databaseId: 'pm',
      collectionId: 'data123',
      documentId: ID.unique(),
    );
  }
}
class ProfilePage extends StatelessWidget {
  final UserController userController = Get.put(UserController());
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _emailController.text = userController.email.value; // Set the initial value

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Obx(() => Text('Name: ${userController.name.value}')),
              Obx(() => Text('Email: ${userController.email.value}')),
              Obx(() => Text('Phone Number: ${userController.phoneNumber.value}')),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    userController.updateData(
                      _nameController.text,
                      _emailController.text,
                      _phoneNumberController.text,
                    );
                    // Replace 'your_collection_id' and 'your_document_id' with your actual IDs
                    userController.updateDataInDatabase('data123', ID.unique());
                  }
                },
                child: const Text('Update Data'),
              ),
              ElevatedButton(
                onPressed: () async {
                  var allDocuments = await userController.listAllDocuments('data123');
                  if (allDocuments.documents.length > 0) {
                    List<Map<String, dynamic>> dataList = [];
                    for (var document in allDocuments.documents) {
                      dataList.add(document.data);
                    }
                    final selected = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditDataPage(dataList: dataList),
                      ),
                    );
                    if (selected != null) {
                      for (int i = 0; i < selected.length; i++) {
                        if (selected[i]) {
                          // Delete or update the data here
                        }
                      }
                    }
                  } else {
                    print('No documents exist');
                  }
                },
                child: const Text('Delete Data'),
              ),
              ElevatedButton(
                      onPressed: () async {
                             if (_formKey.currentState!.validate()) {
                    userController.updateData(
                      _nameController.text,
                      _emailController.text,
                      _phoneNumberController.text,
                    );
                    // Assuming you have the collectionId
                    var response = await userController.createData('data123');
                    var documentId = response['\$id']; // Get the ID of the newly created document
                    await userController.readData('data123', documentId); // Fetch the new data
                  }
                },
                child: const Text('Create Data'),
                      ),
              ElevatedButton(
                onPressed: () async {
                  var allDocuments = await userController.listAllDocuments('data123');
                  if (allDocuments.documents.length > 0) {
                    List<Map<String, dynamic>> dataList = [];
                    for (var document in allDocuments.documents) {
                      dataList.add(document.data);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DataPage(dataList: dataList),
                      ),
                    );
                  } else {
                    print('No documents exist');
                  }
                },
                child: const Text('Show Data'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
//Show Data
class DataPage extends StatelessWidget {
  final List<Map<String, dynamic>> dataList;
  DataPage({required this.dataList});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: dataList.length,
          itemBuilder: (context, index) {
            return Column(
              children: <Widget>[
                Text('Name: ${dataList[index]['name']}'),
                Text('Email: ${dataList[index]['email']}'),
                Text('Phone Number: ${dataList[index]['phoneNumber']}'),
                Divider(),  // Optional: to provide visual separation between data entries
              ],
            );
          },
        ),
      ),
    );
  }
}
//Delete
class EditDataPage extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  EditDataPage({required this.dataList});

  @override
  _EditDataPageState createState() => _EditDataPageState();
}

class _EditDataPageState extends State<EditDataPage> {
  List<bool> selected = [];

  @override
  void initState() {
    super.initState();
    selected = List<bool>.filled(widget.dataList.length, false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Data'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                for (int i = 0; i < selected.length; i++) {
                  if (selected[i]) {
                    // Delete the data here
                    widget.dataList.removeAt(i);
                    // Also update the 'selected' list
                    selected.removeAt(i);
                    // Decrement 'i' so that we don't skip an item
                    i--;
                  }
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: widget.dataList.length,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              title: Text('Name: ${widget.dataList[index]['name']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Email: ${widget.dataList[index]['email']}'),
                  Text('Phone Number: ${widget.dataList[index]['phoneNumber']}'),
                ],
              ),
              value: selected[index],
              onChanged: (bool? value) {
                setState(() {
                  selected[index] = value!;
                });
              },
            );
          },
        ),
      ),
    );
  }
}


//Upload Image
class ThirdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() {
            if (Get.find<ImageController>().pickedImage.value == '') {
              return const Text('No image selected.');
            } else {
              return Image.file(File(Get.find<ImageController>().pickedImage.value));
            }
          }),
          const SizedBox(height: 50), // Menambahkan jarak vertikal sebesar 20 pixel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: () => Get.find<ImageController>().getImage(false),
                // false untuk memilih gambar dari galeri
                tooltip: 'Pick Image from Gallery',
                child: const Icon(Icons.photo_library),
              ),
              FloatingActionButton(
                onPressed: () => Get.find<ImageController>().getImage(true),
                // true untuk memilih gambar dari kamera
                tooltip: 'Pick Image from Camera',
                child: const Icon(Icons.camera),
              ),

              FloatingActionButton(
                onPressed: () => Get.find<ImageController>().deleteImage(),
                tooltip: 'Delete Image',
                child: const Icon(Icons.delete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class ImageController extends GetxController {
  final Client client;
  var pickedImage = ''.obs;
  final picker = ImagePicker();

  ImageController({required this.client});

  Future getImage(bool isCamera) async {
    try {
      final pickedFile = await picker.pickImage(
          source: isCamera ? ImageSource.camera : ImageSource.gallery);

      if (pickedFile != null) {
        // Ubah PickedFile menjadi File
        final File imageFile = File(pickedFile.path);

        // Simpan gambar ke penyimpanan perangkat
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(imageFile.path);
        final savedImage = await imageFile.copy('${appDir.path}/$fileName');

        // Simpan lokasi file gambar
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('pickedImagePath', savedImage.path);

        pickedImage.value = savedImage.path;

        // Upload image to Appwrite
        uploadImage(savedImage);
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('An error occurred while picking the image: $e');
      Get.snackbar("Error", "An error occurred while picking the image");
    }
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      final fileBytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes('file', fileBytes,
          filename: path.basename(imageFile.path));

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('/v1/storage/foto'),
      );

      request.headers.addAll({
        'content-type': 'multipart/form-data',
      });

      request.files.add(multipartFile);
      request.fields['read'] = '*';
      request.fields['write'] = '*';

      final response = await request.send();

      if (response.statusCode == 201) {
        print('Image uploaded successfully');
      } else {
        print('Image upload failed');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void loadSavedImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedImagePath = prefs.getString('pickedImagePath');

      if (savedImagePath != null && File(savedImagePath).existsSync()) {
        pickedImage.value = savedImagePath;
      }
    } catch (e) {
      print('An error occurred while loading the image: $e');
      Get.snackbar("Error", "An error occurred while loading the image");
    }
  }

  void deleteImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedImagePath = prefs.getString('pickedImagePath');

      if (savedImagePath != null && File(savedImagePath).existsSync()) {
        // Hapus file gambar
        await File(savedImagePath).delete();

        // Hapus lokasi file gambar dari shared preferences
        prefs.remove('pickedImagePath');

        // Atur nilai pickedImage menjadi null
        pickedImage.value = '';
      }
    } catch (e) {
      print('An error occurred while deleting the image: $e');
      Get.snackbar("Error", "An error occurred while deleting the image");
    }
  }
}

//Controller/View
Widget buildContainerWithText(String title, String subtitle) {
  return Container(
    width :290,
    padding : const EdgeInsets.all(10),
    decoration : BoxDecoration(
      color : Colors.white,
      borderRadius : BorderRadius.circular(100),
    ),
    child : Column(
      crossAxisAlignment : CrossAxisAlignment.center,
      children : [
        Text(
          title,
          style : const TextStyle(fontSize :15, fontWeight : FontWeight.bold),
        ),
        const SizedBox(height :5), // memberikan jarak antara judul dan teks
        Text(subtitle),
      ],
    ),
  );
}

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  // Metode untuk masuk dengan Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential != null) {
        // Jika berhasil masuk, lakukan sesuatu di sini
        // Misalnya, Anda bisa mengirim notifikasi atau memperbarui UI
      }

      return userCredential;
    } catch (e) {
      print('An error occurred while signing in: $e');
      Get.snackbar("Error", "An error occurred while signing in");
      return null;
    }
  }

  // Metode untuk memeriksa autentikasi
  Future<User?> checkAuthentication() async {
    return _auth.currentUser;
  }

  // Metode untuk keluar
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('An error occurred while signing out: $e');
      Get.snackbar("Error", "An error occurred while signing out");
    }
  }

  // Metode untuk mendaftar dengan email dan password
  Future<UserCredential?> registerWithEmailAndPassword(String email, String password)
  async {
    try {
      // Add password validation
      String pattern = r'^(?=.*?[A-Z])(?=.*?[0-9]).{6,}$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(password)) {
        print('Password must contain at least one uppercase letter, one number, and be at least 6 characters long.');
        Get.snackbar("Error", "Password must contain at least one uppercase letter, one number, and be at least 6 characters long.");
        return null;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        Get.snackbar("Error", "The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        Get.snackbar("Error", "The account already exists for that email.");
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Metode untuk masuk dengan email dan password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        Get.snackbar("Error", "No user found for that email.");
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        Get.snackbar("Error", "Wrong password provided for that user.");
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}


//Controller
class MyApp extends StatelessWidget {
  const MyApp({Key? key});
  @override
  Widget build(BuildContext context) {
    final AuthController _authController = Get.put(AuthController());

    return MaterialApp(
      title: 'JKT48 PM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink),
        useMaterial3: true,
      ),
      home: FutureBuilder<User?>(
        future: _authController.checkAuthentication(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // tampilkan indikator loading saat menunggu
          } else {
            if (snapshot.data != null) {
              return MyHomePage(); // jika pengguna sudah masuk, tampilkan MyHomePage
            } else {
              return LoginPage(); // jika pengguna belum masuk, tampilkan LoginPage
            }
          }
        },
      ),
    );
  }
}

class MessagesController extends GetxController {
  var messages = Message(content: '').obs;
  var isLoading = true.obs;
  @override
  void onInit() {
    fetchMessages();
    super.onInit();
  }
  Future<void> fetchMessages()async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse(
          'https://api.github.com/gists/a3977acb85a45e07d1af0a84e2f94855'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        messages.value = Message.fromJson(jsonDecode(response.body));
        print('Data loaded successfully');
      } else {
        throw Exception('Failed to load messages: ${response.reasonPhrase}');
      }

    } catch (e) {
      print('An error occurred: $e');
      Get.snackbar("Error", "An error occurred while fetching messages");
    } finally {
      isLoading(false);
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = PageController();
  int _currentIndex = 0;
  final List<String> _titles = ['Home', 'Package', 'Upload', 'Messages', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(_titles[_currentIndex]),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.find<AuthController>().signOut().then((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              });
            },
          ),
        ],
      ),

      body: PageView(
        controller: controller,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: <Widget>[
          HomePage(),
          SecondPage(),
          ThirdPage(),
          MessagesPage(),
          ProfilePage(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.pinkAccent,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Package',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: 'Photo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}


import 'package:dar_es_salaam/shared/barrier.dart';
import 'package:dar_es_salaam/shared/progressDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';

// class that let's user add a book to the database
class AddBook extends StatefulWidget {
  @override
  _AddBookState createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  // --------------------- CLASS VARIABLES ----------------------

  String title = '';

  int fieldCount = 0;
  int currentStep = 0;

  File sampleImage;

  List<String> authorList = [];

  final _formKey = GlobalKey<FormState>();

  TextEditingController _titleController = TextEditingController();

  // you must keep track of the TextEditingControllers if you want the values
  // to persist correctly
  List<TextEditingController> controllers = <TextEditingController>[];

  static List<String> _categories = [
    'Fiction',
    'Non-fiction',
    'Children',
    'School Material'
  ];
  String _selectedCategory;
  List<DropdownMenuItem<String>> _dropDownMenuItems;

  // ----------------- END OF VARIABLES --------------------------

// ------------------ CLASS METHODS ----------------------------

// reset the selected item when the user selects a book category
  onDropdownChanged(String selectedCategory) {
    setState(() {
      _selectedCategory = selectedCategory;
    });
  }

// pick image from gallery
  Future pickImageFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    var pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = File(pickedFile.path);
    });
  }

// take photo with camera
  Future takePhotoWithCamera() async {
    ImagePicker imagePicker = ImagePicker();
    var pickedFile = await imagePicker.getImage(source: ImageSource.camera);
    setState(() {
      sampleImage = File(pickedFile.path);
    });
  }

// widget returned when user selects an image or takes one
  Widget enableUpload() {
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
      child: Column(
        children: [
          Image.file(
            sampleImage,
            height: 200.0,
            width: 400.0,
          ),
        ],
      ),
    );
  }

// upload the image to firebase storage and get the download link of the image
  Future<String> uploadImage() async {
    String imageName = title.replaceAll(' ', '_') + '.jpg';
    final StorageReference storageReference =
        FirebaseStorage.instance.ref().child(imageName);
    final StorageUploadTask uploadTask = storageReference.putFile(sampleImage);
    var downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    var url = downloadUrl.toString();
    return url;
  }

// method to build the steps the user has to complete to upload their book
  List<Step> buildSteps(
      {FirestoreService firestoreService,
      AppUser user,
      List<Widget> children}) {
    List<Step> steps = [
      // step 1 - title of book
      Step(
        title: Text('Title'),
        content: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextFormField(
              textCapitalization: TextCapitalization.words,
              controller: _titleController,
              decoration:
                  textInputDecoration.copyWith(hintText: 'Title of book'),
              onChanged: (value) {
                setState(() => title = value);
              },
              validator: (value) =>
                  value.isEmpty ? 'Please provide a valid book title' : null,
            ),
          ),
        ),
        isActive: currentStep >= 0,
      ),

      // step 2 - author of book
      Step(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Author(s)'),
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    fieldCount++;
                  });
                })
          ],
        ),
        content: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: children,
          ),
        ),
        isActive: currentStep >= 1,
      ),

      // step 3 - book category
      Step(
        title: Text('Select a category'),
        content: DropdownButton(
          items: _dropDownMenuItems,
          value: _selectedCategory,
          onChanged: onDropdownChanged,
        ),
        isActive: currentStep >= 2,
      ),

      // step 4 - image of book
      Step(
        title: Text('Image'),
        content: Column(
          children: [
            // show image
            Container(
              child: sampleImage == null ? Container() : enableUpload(),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // pick an image from gallery
                Container(
                  child: FlatButton(
                    child: Text(
                      'Pick from gallery',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                    onPressed: pickImageFromGallery,
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple[100]),
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(5.0)),
                ),

                // take a photo
                Container(
                  child: FlatButton(
                    child: Text(
                      'Take new photo',
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: takePhotoWithCamera,
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.green[100]),
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(5.0)),
                ),
              ],
            ),
          ],
        ),
        isActive: currentStep >= 3,
      ),

      // step 5 - submit book for upload
      Step(
        title: Text('Continue to submit'),
        content: Container(),
        isActive: currentStep >= 4,
      )
    ];
    return steps;
  }

  // create the list of TextFields, based off the list of TextControllers
  List<Widget> _buildTextFields() {
    int i;

    // fill in keys if the list is not long enough (in case we added one)
    if (controllers.length < fieldCount) {
      for (i = controllers.length; i < fieldCount; i++) {
        controllers.add(TextEditingController());
      }
    }

    i = 0;

    // cycle through the controllers, and recreate each, one per available controller
    return controllers.map<Widget>((TextEditingController controller) {
      i++;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                textCapitalization: TextCapitalization.words,
                controller: controller,
                decoration: textInputDecoration.copyWith(hintText: 'Author'),
              ),
            ),
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                // when removing a TextField, you must do two things:
                // 1. decrement the number of controllers you should have (fieldCount)
                // 2. actually remove this field's controller from the list of controllers
                setState(() {
                  fieldCount--;
                  controllers.remove(controller);
                });
              },
            )
          ],
        ),
      );
    }).toList(); // convert to a list
  }

// method that returns the list of drop down categories
  List<DropdownMenuItem<String>> buildDropDownMenuItems(List categories) {
    List<DropdownMenuItem<String>> items = [];
    for (String category in _categories) {
      items.add(DropdownMenuItem(
        value: category,
        child: Text(category),
      ));
    }
    return items;
  }

// ------------ END OF METHODS ----------------------------------

  @override
  void initState() {
    super.initState();
    fieldCount = 1;
    _dropDownMenuItems = buildDropDownMenuItems(_categories);
    _selectedCategory = _dropDownMenuItems[0].value;
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    controllers.forEach((controller) {
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = _buildTextFields();
    final AppUser signedInUser = Provider.of<AppUser>(context);
    FirestoreService firestoreService = FirestoreService(uid: signedInUser.id);

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Upload',
            style: TextStyle(fontFamily: fontFamily),
          ),
          leading: backButton(context: context),
        ),
        body: Stepper(
          physics: BouncingScrollPhysics(),
          steps: buildSteps(
              firestoreService: firestoreService,
              user: signedInUser,
              children: children),
          currentStep: this.currentStep,
          onStepContinue: () {
            setState(() {
              // checking to see if user has reached end of stepper or not
              if (this.currentStep <
                  this
                          .buildSteps(
                              firestoreService: firestoreService,
                              user: signedInUser,
                              children: children)
                          .length -
                      1) {
                this.currentStep = currentStep + 1;
              } else {
                // submit book for upload when user reaches the end of the stepper
                if (_formKey.currentState.validate()) {
                  String imageName = title.replaceAll(' ', '_') + '.jpg';
                  // user can only submit if image file is not null
                  if (sampleImage != null) {
                    controllers.forEach((controller) {
                      authorList.add(controller.text);
                    });

                    // show a loading widget to let the user know what is happening
                    showProgress(context);

                    // upload image to cloud storage and then book to firestore
                    uploadImage().then((downloadUrl) {
                      Book book = Book(
                        title: _titleController.text,
                        authors: authorList.isNotEmpty ? authorList : [],
                        ownerID: signedInUser.id,
                        image: {'url': downloadUrl, 'name': imageName},
                        isAvailable: true,
                        category: _selectedCategory,
                      );

                      String bookID;

                      firestoreService.addBook(book: book).then((value) {
                        bookID = value.id;

                        FirestoreService(uid: value.id).setBookId(value.id);

                        Book bookWithID = Book(
                          title: _titleController.text,
                          authors: authorList.isNotEmpty ? authorList : [],
                          ownerID: signedInUser.id,
                          image: {'url': downloadUrl, 'name': imageName},
                          isAvailable: true,
                          category: _selectedCategory,
                          bookID: bookID,
                        );
                        firestoreService.updateUserBooksDonated(
                          book: bookWithID,
                        );
                      });
                    }).then((Object object) {
                      // dismiss the loading dialog when book has been added to db
                      dismissProgressDialog();

                      Navigator.pop(context);
                      showSnackBar(
                          context: context,
                          message: 'Your book has been uploaded');
                    });
                  } else {
                    showSnackBar(
                        context: context,
                        message: 'Please add an image before submitting');
                  }
                } else {
                  setState(() {
                    currentStep = 0;
                  });
                }
              }
            });
          },
          onStepCancel: () {
            setState(() {
              if (this.currentStep > 0) {
                this.currentStep = this.currentStep - 1;
              } else {
                this.currentStep = 0;
              }
            });
          },
        ));
  }
}

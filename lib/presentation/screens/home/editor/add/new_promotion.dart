import 'package:cenec_app/presentation/screens/home/editor/base.dart';
import 'package:cenec_app/presentation/screens/home/editor/see/promotions.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para usar inputFormatters

class NewPromotion extends StatefulWidget {
  const NewPromotion({super.key});

  @override
  NewPromotionState createState() => NewPromotionState();
}

class NewPromotionState extends State<NewPromotion> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _modalityController = TextEditingController();
  final TextEditingController _subjectIdController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  List<String> locations = [];
  List<String> modalities = [];
  List<String> subjectIds = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _modalityController.dispose();
    _subjectIdController.dispose();
    _imageUrlController.dispose();
    _numberController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                navigateToReplace(context, const BaseEditorPage());
              },
            ),
            const Text("New Promotion"),
          ],
        ),
      ),
      body: Container(
        color: Colors.blueGrey,
        child: Center(
          child: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: "Promotion title",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: "Promotion Description",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter
                          .digitsOnly // Permite solo números
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: "Original Price",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter
                          .digitsOnly // Permite solo números
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: "Discount Porcentage",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: "Image URL",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  _buildLocationField(),
                  _buildLocationsList(),
                  const SizedBox(height: 20),
                  _buildModalityField(),
                  _buildModalitiesList(),
                  const SizedBox(height: 20),
                  _buildSubjectIdField(),
                  _buildSubjectIdsList(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: _savePromotion,
                    child: const Text("Save Promotion",
                        style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Location --- \\\
  Widget _buildLocationField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _locationController,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              labelText: "Add Location",
              labelStyle: const TextStyle(color: Colors.black),
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _addLocation(),
        ),
      ],
    );
  }

  Widget _buildLocationsList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: locations.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(locations[index]),
          trailing: Wrap(
            spacing: 12,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editLocation(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() => locations.removeAt(index)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addLocation() {
    if (_locationController.text.isNotEmpty) {
      setState(() {
        locations.add(_locationController.text);
        _locationController.clear();
      });
    }
  }

  void _editLocation(int index) {
    TextEditingController editController =
        TextEditingController(text: locations[index]);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Location"),
          content: TextField(
            controller: editController,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  locations[index] = editController.text;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  // --- Modality --- \\
  Widget _buildModalityField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _modalityController,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              labelText: "Add Modality",
              labelStyle: const TextStyle(color: Colors.black),
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _addModality(),
        ),
      ],
    );
  }

  Widget _buildModalitiesList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: modalities.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(modalities[index]),
          trailing: Wrap(
            spacing: 12,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editModality(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() => modalities.removeAt(index)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addModality() {
    if (_modalityController.text.isNotEmpty) {
      setState(() {
        modalities.add(_modalityController.text);
        _modalityController.clear();
      });
    }
  }

  void _editModality(int index) {
    TextEditingController editController =
        TextEditingController(text: modalities[index]);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Modality"),
          content: TextField(
            controller: editController,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  modalities[index] = editController.text;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  // --- Subject Ids --- \\
  Widget _buildSubjectIdField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _subjectIdController,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              labelText: "Add Subject ID",
              labelStyle: const TextStyle(color: Colors.black),
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _addSubjectId(),
        ),
      ],
    );
  }

  Widget _buildSubjectIdsList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: subjectIds.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(subjectIds[index]),
          trailing: Wrap(
            spacing: 12,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editSubjectId(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() => subjectIds.removeAt(index)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addSubjectId() {
    if (_subjectIdController.text.isNotEmpty) {
      setState(() {
        subjectIds.add(_subjectIdController.text);
        _subjectIdController.clear();
      });
    }
  }

  void _editSubjectId(int index) {
    TextEditingController editController =
        TextEditingController(text: subjectIds[index]);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Subject ID"),
          content: TextField(
            controller: editController,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  subjectIds[index] = editController.text;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _savePromotion() async {
    try {
      CollectionReference promotions =
          FirebaseFirestore.instance.collection('promotions');
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      DocumentReference newPromotionRef = await promotions.add({
        'title': _nameController.text,
        'description': _descriptionController.text,
        'imagePath': _imageUrlController.text,
        'originalPrice': int.tryParse(_numberController.text) ?? 0,
        'discountPercentage': int.tryParse(_discountController.text) ?? 0,
        'locations': locations,
        'modalities': modalities,
        'subjectIds': subjectIds,
      });
      
      await users.doc(FirebaseAuth.instance.currentUser?.uid).update({
        'c_promotions': FieldValue.arrayUnion([newPromotionRef.id])
      });

      // ignore: use_build_context_synchronously
      navigateToReplace(context, const PromotionsListPage());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving promotion: $e');
      }
    }
  }
}

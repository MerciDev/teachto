import 'package:cenec_app/presentation/screens/home/editor/base.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para usar inputFormatters

class PromotionDetails extends StatefulWidget {
  final String promotionId;
  const PromotionDetails({super.key, required this.promotionId});

  @override
  PromotionDetailsState createState() => PromotionDetailsState();
}

class PromotionDetailsState extends State<PromotionDetails> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _modalityController = TextEditingController();
  final TextEditingController _subjectIdController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  List<String> locations = [];
  List<String> modalities = [];
  List<String> subjectIds = [];
  List<String> options = ['Option 1', 'Option 2', 'Option 3'];
  bool _isEditable = false;

  Map<String, dynamic>? promotionData;

  @override
  void initState() {
    super.initState();
    loadPromotionData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _modalityController.dispose();
    _subjectIdController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> loadPromotionData() async {
    try {
      DocumentSnapshot promotionSnapshot = await FirebaseFirestore.instance
          .collection('promotions')
          .doc(widget.promotionId)
          .get();

      if (promotionSnapshot.exists) {
        setState(() {
          promotionData = promotionSnapshot.data() as Map<String, dynamic>;
        });
        _nameController.text = promotionData!['title'];
        _descriptionController.text = promotionData!['description'];
        _imageUrlController.text = promotionData!['imagePath'];
        _priceController.text =
            (promotionData!['originalPrice'] ?? 0).toString();
        _discountController.text =
            (promotionData!['discountPercentage'] ?? 0).toString();

        List<dynamic> loadedLocations = promotionData!['locations'] ?? [];
        locations = List<String>.from(loadedLocations);

        List<dynamic> loadedModalities = promotionData!['modalities'] ?? [];
        modalities = List<String>.from(loadedModalities);

        List<dynamic> loadedSubjectIds = promotionData!['subjectIds'] ?? [];
        subjectIds = List<String>.from(loadedSubjectIds);
      } else {
        if (kDebugMode) {
          print('No such document!');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading promotion: $e');
      }
    }
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
              const Text("Edit Promotion"),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: _isEditable
                  ? const Icon(Icons.check)
                  : const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditable ? _editPromotion() : null;
                  _isEditable = !_isEditable;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deletePromotion();
              },
            ),
          ]),
      body: Container(
        color: Colors.blueGrey,
        child: Center(
          child: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        "Subject Id: ${widget.promotionId}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: widget.promotionId));
                          },
                          icon: const Icon(Icons.copy)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    enabled: _isEditable,
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
                    enabled: _isEditable,
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
                    enabled: _isEditable,
                    controller: _priceController,
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
                    enabled: _isEditable,
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
                    enabled: _isEditable,
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
                  const SizedBox(height: 20)
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
            enabled: _isEditable,
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
          onPressed: _isEditable ? _addLocation : null,
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
          title: Text(locations[index],
              style: const TextStyle(color: Colors.white)),
          trailing: Wrap(
            spacing: 12,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _isEditable
                    ? () {
                        _editLocation(index);
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _isEditable
                    ? () {
                        setState(() => locations.removeAt(index));
                      }
                    : null,
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
            enabled: _isEditable,
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
            enabled: _isEditable,
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
          onPressed: _isEditable ? _addModality : null,
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
          title: Text(modalities[index],
              style: const TextStyle(color: Colors.white)),
          trailing: Wrap(
            spacing: 12,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _isEditable
                    ? () {
                        _editModality(index);
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _isEditable
                    ? () {
                        setState(() => modalities.removeAt(index));
                      }
                    : null,
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
            enabled: _isEditable,
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
            enabled: _isEditable,
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
          onPressed: _isEditable ? _addSubjectId : null,
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
          title: Text(subjectIds[index],
              style: const TextStyle(color: Colors.white)),
          trailing: Wrap(
            spacing: 12,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _isEditable
                    ? () {
                        _editSubjectId(index);
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _isEditable
                    ? () {
                        setState(() => subjectIds.removeAt(index));
                      }
                    : null,
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
            enabled: _isEditable,
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

  void _editPromotion() async {
    try {
      DocumentReference promotionRef = FirebaseFirestore.instance
          .collection('promotions')
          .doc(widget.promotionId);

      await promotionRef.update({
        'title': _nameController.text,
        'description': _descriptionController.text,
        'originalPrice': int.tryParse(_priceController.text) ?? 0,
        'discountPercentage': int.tryParse(_discountController.text) ?? 0,
        'imagePath': _imageUrlController.text,
        'locations': locations,
        'modalities': modalities,
        'subjectIds': subjectIds,
      });

      setState(() {
        _isEditable = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating promotion: $e');
        if (e is FirebaseException && e.code == 'not-found') {
          print('Document does not exist!');
        }
      }
    }
  }

  void _deletePromotion() async {
    try {
      DocumentReference promotionRef = FirebaseFirestore.instance
          .collection('promotions')
          .doc(widget.promotionId);

      await promotionRef.delete();
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting promotion: $e');
      }
    }
  }
}

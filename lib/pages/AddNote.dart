import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Addnote extends StatefulWidget {
  const Addnote({super.key});

  @override
  State<Addnote> createState() => _AddnoteState();
}

class _AddnoteState extends State<Addnote> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  String _selectedVisibility = 'Public';
  FilePickerResult? _filePickerResult;

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ["pdf"],
      type: FileType.custom,
    );
    setState(() {
      _filePickerResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/b.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment(-0.21, 0),
          opacity: 0.7,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            'Add Note',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInputField(
                controller: titleController,
                hint: "Title",
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: subjectController,
                hint: "Subject",
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: contentController,
                hint: "Add Note Content",
                maxLines: 10,
                minLines: 5,
              ),
              const SizedBox(height: 20),
              _buildVisibilitySection(),
              const SizedBox(height: 20),
              _buildUploadButton(),
              const SizedBox(height: 20),
              _buildAddNoteButton(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
    int? minLines,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: minLines,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: Colors.black.withOpacity(0.7),
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildVisibilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Visibility",
          style: GoogleFonts.poppins(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildVisibilityOption('Public'),
        _buildVisibilityOption('Private'),
        _buildVisibilityOption('Friends Only'),
      ],
    );
  }

  Widget _buildVisibilityOption(String value) {
    return ListTile(
      title: Text(value, style: GoogleFonts.poppins()),
      leading: Radio<String>(
        value: value,
        groupValue: _selectedVisibility,
        onChanged: (value) => setState(() => _selectedVisibility = value!),
      ),
    );
  }

  Widget _buildUploadButton() {
    return _buildStyledButton(
      label: "Upload PDF",
      icon: Icons.picture_as_pdf,
      onPressed: _openFilePicker,
    );
  }

  Widget _buildAddNoteButton() {
    return _buildStyledButton(
      label: "Add Note",
      icon: Icons.arrow_forward,
      onPressed: _saveNote,
    );
  }

  Widget _buildStyledButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8.0),
              child: Icon(icon, color: Colors.black, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote() async {
    try {
      String title = titleController.text.trim();
      String subject = subjectController.text.trim();
      String content = contentController.text.trim();
      User? user = FirebaseAuth.instance.currentUser;

      if (title.isEmpty || subject.isEmpty || content.isEmpty) {
        _showErrorDialog('Please fill all the fields');
        return;
      }

      if (user == null) {
        _showErrorDialog('User not authenticated');
        return;
      }

      await FirebaseFirestore.instance.collection('notes').add({
        'title': title,
        'subject': subject,
        'content': content,
        'visibility': _selectedVisibility,
        'addedBy': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Error saving note: $e');
    }
  }

  void _showSuccessDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Success',
      desc: 'Note Added Successfully',
      btnOkOnPress: () {
        _clearFields();
        Navigator.pop(context);
      },
    ).show();
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'Error',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  void _clearFields() {
    titleController.clear();
    subjectController.clear();
    contentController.clear();
  }
}

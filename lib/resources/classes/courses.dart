import 'package:flutter/material.dart';

import 'models.dart';

class Course {
  final String name;
  final Color color;
  final List<Task> tasks;

  Course({required this.name, required this.color, required this.tasks});
}

List<Course> coursesList = [
  
];

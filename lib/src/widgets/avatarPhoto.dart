import 'dart:io';

import 'package:flutter/material.dart';

class AvatarPhoto {
  Widget image(String url, double size, File image) {
    return Container(
        padding: EdgeInsets.only(top: 40.0),
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: Colors.white,
            /*boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0,
                spreadRadius: .005,
              )
            ],*/
            shape: BoxShape.circle,
            image: DecorationImage(
                fit: BoxFit.contain,
                image: image == null
                    ? url == null
                        ? AssetImage('assets/profile.png')
                        : NetworkImage(url)
                    : FileImage(image))));
  }
}

import 'package:flutter/material.dart';
import 'package:trogon_media/views/home_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/bg.png",fit: BoxFit.cover,),

            Text("Learning anything \nanywhere",textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),),

            SizedBox(height: 50,),
            SizedBox(
              height: 55,
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white,foregroundColor: Colors.black),
                onPressed: (){
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>HomePage()));
                },child: Text('Get Started'),),
            )
          ],
        ),
      ),
    );
  }
}
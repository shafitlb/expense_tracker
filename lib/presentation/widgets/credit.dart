import 'package:flutter/material.dart';

class CreditList extends StatelessWidget {
  const CreditList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) { 
        return Card(
          child: ListTile(
            title: Text('Credit $index'),
            trailing: IconButton(
              icon:const Icon(Icons.delete) ,
              onPressed: () {},),
          ),
        );
       }, 
      itemCount: 10, 
      separatorBuilder: (BuildContext context, int index) { 
        return const SizedBox(height: 10,);
       },);
  }
}
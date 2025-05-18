import 'package:flutter/material.dart';

class HoverCourseCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String instructor;
  final num price;
  final num discount;
  final num rating;

  const HoverCourseCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.instructor,
    required this.price,
    required this.discount,
    required this.rating,
  });

  @override
  _HoverCourseCardState createState() => _HoverCourseCardState();
}

class _HoverCourseCardState extends State<HoverCourseCard> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 200,
        // height: 250,
        margin: const EdgeInsets.only(right: 12),
        transform: isHovering
            ? (Matrix4.identity()..scale(1.05)) 
            : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: isHovering
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 3,
                    offset: const Offset(0, 0),
                  )
                ]
              : [],
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 120,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.instructor,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          "${widget.price}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${widget.discount}",
                          style:  TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            decoration: TextDecoration.combine(
                                [TextDecoration.lineThrough, TextDecoration.underline]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(widget.rating.toString(),
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

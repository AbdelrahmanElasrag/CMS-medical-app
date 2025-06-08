import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cms/screens/service_screen.dart';
import 'package:cms/screens/profile_screen.dart';
import 'package:cms/screens/chatbot_screen.dart';

class Service {
  final String title;
  final String subtitle;
  final String price;
  final String imageUrl;
  final String description;

  Service({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
    required this.description,
  });
}

final List<Service> services = [
  Service(
    title: 'Medical Transport',
    subtitle: 'Transportation • 24/7',
    price: 'Free',
    imageUrl: 'assets/images/bus.jpeg',
    description: 'We offer a free transportation in our vehicle, from your workplace or home to hospitals.',
  ),
  Service(
    title: 'Doctor Booking',
    subtitle: 'Appointment • 24/7',
    price: 'Free',
    imageUrl: 'assets/images/book.jpeg',
    description: 'Easy appointment scheduling with top specialists in various medical fields. We handle all the paperwork and insurance coordination so you can focus on your health.',
  ),
  Service(
    title: 'Follow-Up Care',
    subtitle: 'Health-Care • 24/7',
    price: 'Free',
    imageUrl: 'assets/images/follow.jpeg',
    description: 'We help you follow up on doctors’ reports, test results, and x-rays through our coordinators in each hospital.',
  ),
  Service(
    title: 'Emergency and Accidents',
    subtitle: 'Nursing • 24/7',
    price: 'Free',
    imageUrl: 'assets/images/emergency.jpeg',
    description: '24/7 emergency response service with immediate medical attention and hospital transfer coordination when needed.',
  ),
  Service(
    title: 'Coordinator Service and Registration',
    subtitle: 'Registration • 24/7',
    price: 'Free',
    imageUrl: 'assets/images/reception.jpeg',
    description: 'A coordinator is available to accompany you during your visits from your arrival until the end of your visit to facilitate the registration and entry procedures.',
  ),
];

class HomeScreen extends StatelessWidget {
  final String username;
  final int points;
  final String? profileImageUrl;

  HomeScreen({required this.username, required this.points, this.profileImageUrl,});

  void _showServiceDetails(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(service.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      service.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00C896),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      service.subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      service.price,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      service.description,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceScreen(
                        service: service.title,
                        username: username,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00C896),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Book Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App?'),
            content: Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text('Exit'),
              ),
            ],
          ),
        );
        return shouldExit;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFE6F3EF),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
            GestureDetector(
            onTap: () {
          Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => ProfileScreen(
          username: username,
          points: points,
          ),
          ),
          );
          },
              child: CircleAvatar(
                radius: 24, // A slightly larger radius
                backgroundColor: Colors.grey.shade300,
                // If the URL exists, show the network image.
                // Otherwise, show a fallback person icon.
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : null,
                child: profileImageUrl == null
                    ? const Icon(
                  Icons.person,
                  size: 28,
                  color: Colors.white,
                )
                    : null,
              ),
            ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $username 👋',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Text(
                          "Let's find your service!",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.grey[800],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: points / 80.0,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(Color(0xFF00C896)),
                            ),
                          ),
                          Text(
                            '$points',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00C896),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Current Score!',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: Text('Point System', style: TextStyle(color: Color(0xFF00C896))),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('🎯 Earn points by using our services!'),
                                          SizedBox(height: 10),
                                          Text('Here is how you can earn points:'),
                                          SizedBox(height: 5),
                                          Text('• For each visit earn 100 points'),
                                          SizedBox(height: 10),
                                          Text('🏆 Reach 1000 points to win a gift!'),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text(
                                            'Got it',
                                            style: TextStyle(color: Color(0xFF00C896)),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text('Point System >'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF00C896),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.15,
                          child: Image.asset(
                            'assets/images/newlogo.png',
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Know more about us!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 12,
                        child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Text('About Us'),
                                  content: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'We are Creative Multi-Solution, a company dedicated to providing essential medical services to make healthcare more accessible for everyone.\n\n',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '📌 Our Goals:\n',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '• Raise awareness and promote health education.\n',
                                        ),
                                        TextSpan(
                                          text: '• Maintain the health of individuals and families.\n',
                                        ),
                                        TextSpan(
                                          text: '• Spread the importance of healthcare in the community.\n\n',
                                        ),
                                        TextSpan(
                                          text: '🌟 We offer exclusive VIP services for members only:\n\n',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '✅ Booking and follow-up of appointments.\n',
                                          style: TextStyle(
                                            color: Color(0xFFC89600),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '🚗 Transportation to and from work or home to hospitals.\n',
                                          style: TextStyle(
                                            color: Color(0xFFC89600),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '🤝 Assistance upon arrival with a representative to ease registration and entry into various departments.\n',
                                          style: TextStyle(
                                            color: Color(0xFFC89600),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '⏱️ Save waiting time.\n',
                                          style: TextStyle(
                                            color: Color(0xFFC89600),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '🩺 Follow-up on doctor reports, lab results, and X-rays.\n',
                                          style: TextStyle(
                                            color: Color(0xFFC89600),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '🕒 Services available 24/7.\n',
                                          style: TextStyle(
                                            color: Color(0xFFC89600),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '🚨 Emergency and accident services available.\n',
                                          style: TextStyle(
                                            color: Color(0xFFC89600),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '🎁 Services are free for a limited time only.\n',
                                          style: TextStyle(
                                            color: Color(0xFFC80032),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text(
                                        'Close',
                                        style: TextStyle(
                                          color: Color(0xFF00C896),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            'Press Here',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Services',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    // TextButton(onPressed: () {}, child: Text('See All')),
                  ],
                ),
                SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.90,
                  ),
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ServiceCard(
                      title: service.title,
                      subtitle: service.subtitle,
                      price: service.price,
                      imageUrl: service.imageUrl,
                      onTap: () => _showServiceDetails(context, service),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) { // Profile
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    username: username,
                    points: points,
                  ),
                ),
              );
            }
            else if (index == 2) { // Chatbot - THIS IS THE NEW LOGIC
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatbotScreen(),
                ),
              );
            }
            // Home is index 1 (handled automatically)
            // Settings is index 2 (you can implement this later)
          },
          selectedItemColor: Color(0xFF00C896),
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined), // A great robot-like icon
              activeIcon: Icon(Icons.smart_toy),    // A solid version for when it's active
              label: 'Assistant',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceScreen(
                  service: 'Quick Booking',
                  username: username,
                ),
              ),
            );
          },
          backgroundColor: Color(0xFF00C896),
          icon: Icon(Icons.add, color: Colors.white,),

          label: Text(
            'BOOK NOW',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String imageUrl;
  final VoidCallback onTap;

  const ServiceCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            Spacer(),
            Text(
              price,
              style: TextStyle(
                color: Color(0xFF00C896),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
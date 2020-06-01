class User {

  final String uid;

  User({ this.uid });

}

class UserData {

  final String uid;
  final String firstName;
  final double latitude;
  final double longitude;
  final List<User> closeFriends;

  UserData({ this.uid, this.firstName, this.latitude, this.longitude, this.closeFriends });

}


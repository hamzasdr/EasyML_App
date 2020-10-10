
class User{
  int id;
  String username;
  String avatar;
  String token;

  User({this.id, this.username, this.avatar, this.token});

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      avatar: json['avatar'] as String,
      token: json['token'] as String
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'avatar': avatar,
    'token': token
  };

}
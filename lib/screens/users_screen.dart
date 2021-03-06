import 'package:chat_app/models/user.dart';
import 'package:chat_app/services/chat_services.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../services/auth_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

RefreshController _refreshController = RefreshController(initialRefresh: false);
final userService = UsersServices();

class _UsersScreenState extends State<UsersScreen> {
  List<User> users = [];
  // final users = [
  //   User(uid: '1', name: 'Luis', email: 'Luis@gmail.com', online: true),
  //   User(uid: '2', name: 'Miguel', email: 'Miguel@gmail.com', online: true),
  //   User(uid: '3', name: 'andres', email: 'andress@gmail.com', online: false)
  // ];
  @override
  void initState() {
    // TODO: implement initState
    _loadUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authservice = Provider.of<AuthService>(context);
    final socketservice = Provider.of<SocketService>(context);
    final user = authservice.user;

    return Scaffold(
        appBar: AppBar(
          title: Text(user.name, style: const TextStyle(color: Colors.black54)),
          elevation: 1,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.black54,
            ),
            onPressed: () {
              // Desconnect to Socket Server
              socketservice.disconnect();
              Navigator.pushReplacementNamed(context, 'login');
              AuthService.deleteToken();
            },
          ),
          actions: <Widget>[
            Container(
                margin: const EdgeInsets.only(right: 10),
                child: (socketservice.serverStatus == ServerStatus.onlline)
                    ? const Icon(Icons.check_circle, color: Colors.blue)
                    : const Icon(Icons.offline_bolt, color: Colors.red))
          ],
        ),
        body: SmartRefresher(
            enablePullDown: true,
            onRefresh: _loadUsers,
            header: WaterDropHeader(
              complete: Icon(
                Icons.check,
                color: Colors.blue[400],
              ),
              waterDropColor: Colors.blue,
            ),
            child: _listViewUsers(),
            controller: _refreshController));
  }

  _loadUsers() async {
    users = await userService.getUsers();
    setState(() {});
    // monitor network fetch
    // await Future.delayed(Duration(milliseconds: 1000));
    // // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  ListView _listViewUsers() {
    return ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, i) => _userListTile(users[i]),
        separatorBuilder: (_, i) => Divider(),
        itemCount: users.length);
  }

  ListTile _userListTile(User user) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text(user.email),
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Text(user.name.substring(0, 2)),
      ),
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: user.online ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(100)),
      ),
      onTap: () {
        final chatService = Provider.of<ChatService>(context, listen: false);
        chatService.userPara = user;
        Navigator.pushNamed(context, 'chat');
      },
    );
  }
}

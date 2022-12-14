import 'package:dor_app/controller/access_token_controller.dart';
import 'package:dor_app/dio/game/update_my_game_nickname.dart';
import 'package:dor_app/utils/color_palette.dart';
import 'package:dor_app/utils/woojoo_games.dart';
import 'package:dor_app/utils/notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameCard extends StatefulWidget {
  const GameCard(
      {Key? key,
      required this.gameName,
      required this.isMe,
      required this.nickname})
      : super(key: key);

  final String gameName;
  final String? nickname;
  final bool isMe;

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  final _textFieldController = TextEditingController();
  String? nickname;

  @override
  void initState() {
    super.initState();
    setState(() {
      nickname = widget.nickname;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isMe) Get.toNamed('/friends/${widget.gameName}');
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0, bottom: 8.0, top: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Stack(children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                  Colors.black87.withOpacity(0.2), BlendMode.srcOver),
              child: Container(
                width: 150,
                height: 230,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                          "assets/images/game/${widget.gameName}.jpg"),
                      fit: BoxFit.cover),
                ),
                child: Container(
                  constraints: const BoxConstraints.expand(),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Color.fromARGB(255, 0, 0, 0),
                      ],
                      stops: [0.0, 0.5, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 10,
              left: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        if (widget.isMe) _showTextInputDialog(context);
                      },
                      child: Text(
                        nickname == null
                            ? (widget.isMe ? '????????? ????????????' : '')
                            : nickname!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1, 0),
                                blurRadius: 5.0,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ],
                            backgroundColor: Color.fromARGB(89, 0, 0, 0)),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      changeKorGameName(widget.gameName), // .jpg, .png ????????? ??????
                      style: const TextStyle(
                          color: Color.fromARGB(255, 199, 199, 199),
                          fontSize: 15),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ),

            // if (nickname != null) ...[
            //   Positioned(
            //     bottom: 26,
            //     left: 2,
            //     child: InkWell(
            //       onTap: () {
            //         if (widget.isMe) _showTextInputDialog(context);
            //       },
            //       child: SizedBox(
            //         height: 30,
            //         width: 140,
            //         child: Container(
            //           padding: const EdgeInsets.only(left: 8, top: 5),
            //           child: Text(
            //             nickname!,
            //             style: const TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 19,
            //                 fontWeight: FontWeight.w400,
            //                 shadows: <Shadow>[
            //                   Shadow(
            //                     offset: Offset(1, 0),
            //                     blurRadius: 5.0,
            //                     color: Color.fromARGB(255, 0, 0, 0),
            //                   ),
            //                 ],
            //                 backgroundColor: Color.fromARGB(89, 0, 0, 0)),
            //             textAlign: TextAlign.start,
            //           ),
            //         ),
            //       ),
            //     ),
            //   )
            // ],
            // if (nickname == null) ...[
            //   Positioned(
            //     bottom: 26,
            //     left: 2,
            //     child: InkWell(
            //       onTap: () {
            //         _showTextInputDialog(context);
            //       },
            //       child: SizedBox(
            //         height: 30,
            //         width: 150,
            //         child: Container(
            //           padding: const EdgeInsets.only(left: 8, top: 5),
            //           child: const Text(
            //             '????????? ????????????',
            //             style: TextStyle(
            //               color: Color.fromARGB(228, 255, 255, 255),
            //               fontSize: 15,
            //               fontWeight: FontWeight.w400,
            //             ),
            //             textAlign: TextAlign.left,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ],
            if (widget.isMe) ...[
              Positioned(
                top: 7,
                right: 5,
                child: Material(
                  color: const Color.fromARGB(0, 255, 255, 255),
                  child: IconButton(
                      onPressed: () {
                        _showTextInputDialog(context);
                      },
                      tooltip: "????????? ??????",
                      splashRadius: 14,
                      padding: const EdgeInsets.all(3.0),
                      constraints: const BoxConstraints(),
                      splashColor: const Color.fromARGB(169, 255, 255, 255),
                      icon: const Icon(Icons.settings,
                          color: Color.fromARGB(178, 255, 255, 254), size: 20)),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  Future<String?> _showTextInputDialog(BuildContext context) async {
    final enabledBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide:
            const BorderSide(color: Color.fromARGB(0, 52, 52, 71), width: 2));
    final focusedBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide:
            const BorderSide(color: Color.fromARGB(0, 52, 52, 71), width: 2));

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            backgroundColor: ColorPalette.mainBackgroundColor,
            contentPadding: const EdgeInsets.only(top: 10, right: 20, left: 20),
            actionsAlignment: MainAxisAlignment.spaceAround,
            title: SizedBox(
              height: 80,
              child: Column(
                children: [
                  Text(
                    changeKorGameName(widget.gameName),
                    style:
                        const TextStyle(color: ColorPalette.font, fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    '???????????? ??? ??? ?????? ???????????? ??????????????????',
                    style: TextStyle(color: ColorPalette.subFont, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            content: SizedBox(
              height: 65,
              child: TextField(
                maxLength: 20,
                cursorColor: ColorPalette.font,
                autofocus: true,
                controller: _textFieldController,
                style:
                    const TextStyle(fontSize: 19.0, color: ColorPalette.font),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 66, 73, 92),
                  enabledBorder: enabledBorder,
                  focusedBorder: focusedBorder,
                  counterStyle: const TextStyle(color: ColorPalette.subFont),
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text(
                    '??????',
                    style: TextStyle(color: ColorPalette.font, fontSize: 20),
                  )),
              TextButton(
                  onPressed: () {
                    if (_textFieldController.text.isNotEmpty) {
                      _updateGameNickname();
                    }
                    Get.back();
                  },
                  child: const Text(
                    '??????',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 20),
                  )),
            ],
          );
        });
  }

  _updateGameNickname() {
    String accessToken = Get.find<AccessTokenController>().accessToken;
    Future<Map<String, dynamic>> response = dioApiUpdateMyGamesNickname(
        accessToken, widget.gameName, _textFieldController.text);
    response.then((res) {
      int statusCode = res['statusCode'];
      if (statusCode == 200) {
        setState(() {
          nickname = _textFieldController.text;
        });
      } else {
        notification(context, '??????: $statusCode');
      }
    });
  }
}

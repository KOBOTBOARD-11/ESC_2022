import 'package:carkeeper/commons/common_form_field.dart';
import 'package:carkeeper/firebase/record_data_list.dart';
import 'package:carkeeper/pages/record_pages/amplify_user_pic.dart';
import 'package:carkeeper/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  var _snapshot = FirebaseFirestore.instance.collection('pictures').snapshots();
  bool human = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "감지 내역",
            style: h5(mColor: const Color(0xFF06A66C)),
          ),
          elevation: 1,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                setState(() async {
                  recordInfo.clear();
                  await FirebaseFirestore.instance
                      .collection('pictures')
                      .doc('pic0')
                      .delete();
                });
              },
              icon: const Icon(
                Icons.delete,
                color: Color(0xFF06A66C),
              ),
            ),
            IconButton(
              onPressed: () async {
                final url = Uri.parse('tel:119');
                if (await canLaunchUrl(url)) {
                  launchUrl(url);
                } else {
                  // ignore: avoid_print
                  print("Can't launch $url");
                }
              },
              icon: const Icon(
                Icons.dialer_sip,
                color: Color(0xFF06A66C),
              ),
            ),
          ],
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFe9e9e9),
            ],
            stops: [
              0.5,
              1,
            ],
          )),
          child: StreamBuilder<QuerySnapshot>(
              stream: _snapshot,
              builder: (context, snapshot) {
                if (snapshot.data?.size == 0) {
                  // snapshot 데이터가 비어있으면
                  return SizedBox(
                    // 즉, 컬렉션에 아무것도 없으면 No Data를 출력한다.
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: Text(
                        "No Data",
                        style: h4(mColor: const Color(0xFF06A66C)),
                      ),
                    ),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  // snapshot 데이터를 가져오고 있을 때
                  return const SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF06A66C)),
                    ),
                  );
                } else {
                  if (recordInfo.isEmpty ||
                      snapshot.data?.docs.last['time'] !=
                          recordInfo.last['time']) {
                    recordInfo.add(snapshot.data?.docs.last.data());
                    // recordInfo에 해당 Snapshot의 Data를 넣는다.
                  }

                  return Container(
                    padding: const EdgeInsets.only(
                        left: 30, right: 30, top: 15, bottom: 15),
                    // recordInfo에 들어간 데이터만큼 record_page에 해당 데이터들을 넣는다.
                    alignment: Alignment.center,
                    child: ListView.builder(
                      itemCount: recordInfo.length,
                      itemBuilder: (context, index) {
                        return (recordInfo[index]['type'] == 'human')
                            ? _buildRecordContainer(
                                recordInfo[index]['pic'],
                                recordInfo[index]['user_pic'],
                                recordInfo[index]['user_type'],
                                recordInfo[index]['time'],
                                recordInfo[index]['type'],
                              )
                            : _buildRecordContainer(
                                recordInfo[index]['pic'],
                                "no",
                                0,
                                recordInfo[index]['time'],
                                recordInfo[index]['type'],
                              );
                      },
                    ),
                  );
                }
              }),
        ));
  }

  Container _buildRecordContainer(String imageUrl, String userImageUrl,
      int userType, String date, String info) {
    bool owner = false;
    if (userType == 2) {
      owner = true;
    } else if (userType == 1 || userType == 0) {
      owner = false;
    }
    if (info == 'wildboar') {
      info = "멧돼지";
      human = false;
    } else if (info == 'human') {
      info = "사람";
      human = true;
    } else if (info == 'dog') {
      info = "들개";
      human = false;
    } else if (info == 'waterdeer') {
      info = "고라니";
      human = false;
    } else if (info == 'racoon') {
      info = "너구리";
      human = false;
    } else {
      date = "No";
      info = "No";
      human = false;
    }
    return Container(
      decoration: buttonStyle1(),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            alignment: Alignment.center,
            height: 250,
            child: Stack(
              children: [
                ExtendedImage.network(
                  imageUrl,
                  fit: BoxFit.fitWidth,
                  cache: false,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 220),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: human
                                  ? (owner
                                      ? const Color(0xFF73FF00)
                                      : Colors.red)
                                  : Colors.transparent,
                              width: 5,
                            ),
                            borderRadius: BorderRadius.circular(90),
                          ),
                          child: human
                              ? InkWell(
                                  onDoubleTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AmplifyUserPic(
                                                    userImageSrc:
                                                        userImageUrl)));
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(90),
                                    child: ExtendedImage.network(
                                      userImageUrl,
                                      height: 90,
                                      width: 90,
                                      fit: BoxFit.cover,
                                      cache: false,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: Colors.transparent,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            //color: Color(0xFFA7D2CB),
            child: CommonFormField(date: date, info: info),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

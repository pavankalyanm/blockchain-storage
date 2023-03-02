import 'dart:async';
import 'dart:ffi';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/sun_moon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/data/repositories/firestore_crud.dart';
import 'package:todo_app/presentation/widgets/mybutton.dart';
import 'package:todo_app/presentation/widgets/mytextfield.dart';
import 'package:todo_app/presentation/widgets/progressindicator.dart';
import 'package:todo_app/shared/constants/consts_variables.dart';
import 'package:todo_app/shared/styles/colors.dart';
import 'package:random_string/random_string.dart';
import 'dart:math' show Random;
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '../../../shared/services/notification_service.dart';

class GenerateCodePage extends StatefulWidget {
  final TaskModel? task;

  const GenerateCodePage({
    this.task,
    Key? key,
  }) : super(key: key);

  @override
  State<GenerateCodePage> createState() => _GenerateCodePageState();
}

class _GenerateCodePageState extends State<GenerateCodePage> {
  get isEditMote => widget.task != null;

  late TextEditingController _titlecontroller;
  late TextEditingController _notecontroller;
  late DateTime currentdate;
  static var _starthour = TimeOfDay.now();
  var code;
  var semid;
  var subject;
  var hours;
  var endhour = TimeOfDay.now();

  final _formKey = GlobalKey<FormState>();
  late int _selectedReminder;
  late int _selectedcolor;
  var setDefaultMake = true;

  final interval = const Duration(seconds: 1);

  final int timerMaxSeconds = 60;

  int currentSeconds = 0;

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimeout([int? milliseconds]) {
    var duration = interval;
    Timer.periodic(duration, (timer) {
      setState(() {
        print(timer.tick);
        currentSeconds = timer.tick;
        if (timer.tick >= timerMaxSeconds) timer.cancel();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _titlecontroller =
        TextEditingController(text: isEditMote ? widget.task!.title : '');
    _notecontroller =
        TextEditingController(text: isEditMote ? widget.task!.note : '');

    currentdate =
        isEditMote ? DateTime.parse(widget.task!.date) : DateTime.now();
    endhour = TimeOfDay(
      hour: _starthour.hour + 1,
      minute: _starthour.minute,
    );
    _selectedReminder = isEditMote ? widget.task!.reminder : 5;
    _selectedcolor = isEditMote ? widget.task!.colorindex : 0;
  }

  @override
  void dispose() {
    super.dispose();
    _titlecontroller.dispose();
    _notecontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _buildform(context),
          ),
        ),
      ),
    );
  }

  Form _buildform(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 1.h,
          ),
          _buildAppBar(context),
          SizedBox(
            height: 3.h,
          ),
          Text(
            'Class Code',
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(fontSize: 14.sp),
          ),
          SizedBox(
            height: 1.h,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('class').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              // Safety check to ensure that snapshot contains data
              // without this safety check, StreamBuilder dirty state warnings will be thrown
              if (!snapshot.hasData) return CircularProgressIndicator();
              // Set this value for default,
              // setDefault will change if an item was selected
              // First item from the List will be displayed

              return DropdownButtonFormField(
                //isExpanded: false,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 9.sp, color: Colors.deepPurple),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.deepPurple,
                  size: 25.sp,
                ),
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 0,
                      )),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                ),
                value: code,
                items: snapshot.data!.docs.map((value) {
                  return DropdownMenuItem(
                    value: value.get('code'),
                    child: Text('${value.get('code')}'),
                  );
                }).toList(),
                onChanged: (value) {
                  debugPrint('selected onchange: $value');
                  setState(
                    () {
                      debugPrint('make selected: $value');
                      // Selected value will be stored
                      semid = null;
                      subject = null;
                      code = value;

                      // Default dropdown value won't be displayed anymore
                      setDefaultMake = false;
                      // Set makeModel to true to display first car from list
                      // setDefaultMakeModel = true;
                    },
                  );
                },
              );
            },
          ),
          SizedBox(
            height: 2.h,
          ),
          Text(
            'Semester',
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(fontSize: 14.sp),
          ),
          SizedBox(
            height: 1.h,
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('semester').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              // Safety check to ensure that snapshot contains data
              // without this safety check, StreamBuilder dirty state warnings will be thrown
              if (!snapshot.hasData) return CircularProgressIndicator();
              // Set this value for default,
              // setDefault will change if an item was selected
              // First item from the List will be displayed

              return DropdownButtonFormField(
                //isExpanded: false,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 9.sp, color: Colors.deepPurple),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.deepPurple,
                  size: 25.sp,
                ),
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 0,
                      )),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                ),
                value: semid,
                items: snapshot.data!.docs.map((value) {
                  return DropdownMenuItem(
                    value: value.get('semid'),
                    child: Text('${value.get('semid')}'),
                  );
                }).toList(),
                onChanged: (value) {
                  debugPrint('selected onchange: $value');
                  setState(
                    () {
                      debugPrint('make selected: $value');
                      // Selected value will be stored
                      subject = null;
                      semid = value;
                      // Default dropdown value won't be displayed anymore
                      setDefaultMake = false;
                      // Set makeModel to true to display first car from list
                      // setDefaultMakeModel = true;
                    },
                  );
                },
              );
            },
          ),
          SizedBox(
            height: 2.h,
          ),
          Text(
            'Subject',
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(fontSize: 14.sp),
          ),
          SizedBox(
            height: 1.h,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('semester')
                .doc(semid)
                .collection('courses')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              // Safety check to ensure that snapshot contains data
              // without this safety check, StreamBuilder dirty state warnings will be thrown
              if (!snapshot.hasData) return CircularProgressIndicator();
              // Set this value for default,
              // setDefault will change if an item was selected
              // First item from the List will be displayed

              return DropdownButtonFormField(
                //isExpanded: false,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 9.sp, color: Colors.deepPurple),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.deepPurple,
                  size: 25.sp,
                ),
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 0,
                      )),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                ),
                value: subject,
                items: snapshot.data!.docs.map((value) {
                  return DropdownMenuItem(
                    value: value.get('coursename'),
                    child: Text('${value.get('coursename')}'),
                  );
                }).toList(),
                onChanged: (value) {
                  debugPrint('selected onchange: $value');
                  setState(
                    () {
                      debugPrint('make selected: $value');
                      // Selected value will be stored
                      subject = value;
                      // Default dropdown value won't be displayed anymore
                      setDefaultMake = false;
                      // Set makeModel to true to display first car from list
                      // setDefaultMakeModel = true;
                    },
                  );
                },
              );
            },
          ),
          SizedBox(
            height: 2.h,
          ),
          /* Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Time',
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    MyTextfield(
                      hint: DateFormat('HH:mm a').format(DateTime(
                          0, 0, 0, _starthour.hour, _starthour.minute)),
                      icon: Icons.watch_outlined,
                      showicon: false,
                      readonly: true,
                      validator: (value) {},
                      ontap: () {
                        Navigator.push(
                            context,
                            showPicker(
                              value: _starthour,
                              is24HrFormat: true,
                              accentColor: Colors.deepPurple,
                              onChange: (TimeOfDay newvalue) {
                                setState(() {
                                  _starthour = newvalue;
                                  endhour = TimeOfDay(
                                    hour: _starthour.hour < 22
                                        ? _starthour.hour + 1
                                        : _starthour.hour,
                                    minute: _starthour.minute,
                                  );
                                });
                              },
                            ));
                      },
                      textEditingController: TextEditingController(),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 4.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Time',
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    MyTextfield(
                      hint: DateFormat('HH:mm a').format(
                          DateTime(0, 0, 0, endhour.hour, endhour.minute)),
                      icon: Icons.watch,
                      showicon: false,
                      readonly: true,
                      validator: (value) {},
                      ontap: () {
                        Navigator.push(
                            context,
                            showPicker(
                              value: endhour,
                              is24HrFormat: true,
                              minHour: _starthour.hour.toDouble() - 1,
                              accentColor: Colors.deepPurple,
                              onChange: (TimeOfDay newvalue) {
                                setState(() {
                                  endhour = newvalue;
                                });
                              },
                            ));
                      },
                      textEditingController: TextEditingController(),
                    ),
                  ],
                ),
              ),
            ],
          ),*/
          SizedBox(
            height: 2.h,
          ),
          Text(
            'Hours',
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(fontSize: 14.sp),
          ),
          SizedBox(
            height: 1.h,
          ),
          //_buildDropdownButton(context),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('periods').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              // Safety check to ensure that snapshot contains data
              // without this safety check, StreamBuilder dirty state warnings will be thrown
              if (!snapshot.hasData) return CircularProgressIndicator();
              // Set this value for default,
              // setDefault will change if an item was selected
              // First item from the List will be displayed

              return DropdownButtonFormField(
                //isExpanded: false,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 9.sp, color: Colors.deepPurple),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.deepPurple,
                  size: 25.sp,
                ),
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 0,
                      )),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                ),
                value: hours,
                items: snapshot.data!.docs.map((value) {
                  return DropdownMenuItem(
                    value: value.get('time'),
                    child: Text('${value.get('time')}'),
                  );
                }).toList(),
                onChanged: (value) {
                  debugPrint('selected onchange: $value');
                  setState(
                    () {
                      debugPrint('make selected: $value');
                      // Selected value will be stored

                      hours = value;

                      // Default dropdown value won't be displayed anymore
                      setDefaultMake = false;
                      // Set makeModel to true to display first car from list
                      // setDefaultMakeModel = true;
                    },
                  );
                },
              );
            },
          ),
          SizedBox(
            height: 2.h,
          ),
          /*Text(
            'Colors',
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(fontSize: 14.sp),
          ),*/
          SizedBox(
            height: 1.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /*Wrap(
                children: List<Widget>.generate(
                    3,
                    (index) => Padding(
                          padding: EdgeInsets.only(right: 2.w),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedcolor = index;
                              });
                            },
                            child: CircleAvatar(
                                backgroundColor: colors[index],
                                child: _selectedcolor == index
                                    ? const Icon(
                                        Icons.done,
                                        color: Appcolors.white,
                                      )
                                    : null),
                          ),
                        )),
              ),*/
              Center(
                child: MyButton(
                  color: isEditMote ? Colors.green : Colors.deepPurple,
                  width: 40.w,
                  title: 'Generate Code',
                  func: () async {
                    _addtask(context, code);
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  //_addData(uniqueId, progress) async {}
  _addtask(ctx, String code) async {
    if (_formKey.currentState!.validate()) {
      LoadingIndicatorDialog().show(ctx, 'Generating Code');
      var uniqueId = randomAlphaNumeric(6);
      await FireStoreCrud().generateId(uniqueId: uniqueId, classid: code);
      LoadingIndicatorDialog().dismiss();

      Dialogs.materialDialog(
          barrierDismissible: false,
          msg: timerText,
          title: uniqueId,
          color: Colors.white,
          context: context,
          titleStyle:
              const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          actions: [
            const SlideCountdownSeparated(
              duration: Duration(minutes: 2),
            ),
            IconsOutlineButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'Stop',
              iconData: Icons.cancel_outlined,
              textStyle: TextStyle(color: Colors.grey),
              iconColor: Colors.grey,
            ),
            IconsButton(
              onPressed: () {},
              text: 'Mark',
              iconData: Icons.chevron_right_rounded,
              color: Colors.deepPurple,
              textStyle: TextStyle(color: Colors.white),
              iconColor: Colors.white,
            ),
          ]);
      // ADDING TASK
      /*TaskModel task = TaskModel(
        title: _titlecontroller.text,
        note: _notecontroller.text,
        date: DateFormat('yyyy-MM-dd').format(currentdate),
        starttime: _starthour.format(context),
        endtime: endhour.format(context),
        reminder: _selectedReminder,
        colorindex: _selectedcolor,
        id: '',
      );
      isEditMote
          ? FireStoreCrud().updateTask(
              docid: widget.task!.id,
              title: _titlecontroller.text,
              note: _notecontroller.text,
              date: DateFormat('yyyy-MM-dd').format(currentdate),
              starttime: _starthour,
              endtime: endhour.format(context),
              reminder: _selectedReminder,
              colorindex: _selectedcolor,
            )
          : FireStoreCrud().addTask(task: task);

      NotificationsHandler.createScheduledNotification(
        date: currentdate.day,
        hour: _starthour.hour,
        minute: _starthour.minute - _selectedReminder,
        title: '${Emojis.time_watch} It Is Time For Your Task!!!',
        body: _titlecontroller.text,
      );

      NotificationsHandler.createScheduledNotification(
        date: currentdate.day,
        hour: endhour.hour,
        minute: endhour.minute - _selectedReminder,
        title: '${Emojis.time_watch} Your task ends now!!!',
        body: _titlecontroller.text,
      );

      Navigator.pop(context);*/
    }
  }

  _buildDropdownButton(
      BuildContext context, AsyncSnapshot snapshot, String column) {
    return DropdownButtonFormField(
      //isExpanded: false,
      style: Theme.of(context)
          .textTheme
          .headline1!
          .copyWith(fontSize: 9.sp, color: Colors.deepPurple),
      icon: Icon(
        Icons.arrow_drop_down,
        color: Colors.deepPurple,
        size: 25.sp,
      ),
      decoration: InputDecoration(
        fillColor: Colors.grey.shade200,
        filled: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              width: 0,
            )),
        contentPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      ),
      value: code,
      items: snapshot.data!.docs.map((value) {
        return DropdownMenuItem(
          value: value.get(column),
          child: Text('${value.get(column)}'),
        );
      }).toList(),
      onChanged: (value) {
        debugPrint('selected onchange: $value');
        setState(
          () {
            debugPrint('make selected: $value');
            // Selected value will be stored
            code = value;
            // Default dropdown value won't be displayed anymore
            //setDefaultMake = false;
            // Set makeModel to true to display first car from list
            //setDefaultMakeModel = true;
          },
        );
      },
    );
  }

  _showdatepicker() async {
    var selecteddate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2200),
      currentDate: DateTime.now(),
    );
    setState(() {
      selecteddate != null ? currentdate = selecteddate : null;
    });
  }

  Row _buildAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.chevron_left,
            size: 30.sp,
          ),
        ),
        Text(
          'Mark Attendance',
          style: Theme.of(context).textTheme.headline1,
        ),
        const SizedBox()
      ],
    );
  }
}

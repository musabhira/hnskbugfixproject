import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_page_model.dart';
export 'auth_page_model.dart';

import 'package:pocket_mates_app/custom_code/widgets/legal_policy_widget.dart';

class AuthPageWidget extends StatefulWidget {
  const AuthPageWidget({super.key});

  static String routeName = 'Auth_page';
  static String routePath = '/authPage';

  @override
  State<AuthPageWidget> createState() => _AuthPageWidgetState();
}

class _AuthPageWidgetState extends State<AuthPageWidget>
    with TickerProviderStateMixin {
  late AuthPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  final animationsMap = <String, AnimationInfo>{};
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthPageModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    _model.emailAddressCreateTextController ??= TextEditingController();
    _model.emailAddressCreateFocusNode ??= FocusNode();

    _model.passwordCreateTextController ??= TextEditingController();
    _model.passwordCreateFocusNode ??= FocusNode();

    _model.passwordCreateConformTextController ??= TextEditingController();
    _model.passwordCreateConformFocusNode ??= FocusNode();

    animationsMap.addAll({
      'columnOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: const Offset(0.0, 60.0),
            end: const Offset(0.0, 0.0),
          ),
          TiltEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: const Offset(-0.349, 0),
            end: const Offset(0, 0),
          ),
        ],
      ),
      'columnOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: const Offset(0.0, 60.0),
            end: const Offset(0.0, 0.0),
          ),
          TiltEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: const Offset(-0.349, 0),
            end: const Offset(0, 0),
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.black,
        body: SafeArea(
          top: true,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 8,
                child: Container(
                  width: 100.0,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  alignment: const AlignmentDirectional(0.0, -1.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 44.0, 0.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(
                              maxWidth: 602.0,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 700.0,
                          constraints: const BoxConstraints(
                            maxWidth: 602.0,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: Column(
                              children: [
                                Align(
                                  alignment: const Alignment(-1.0, 0),
                                  child: TabBar(
                                    isScrollable: true,
                                    labelColor: Colors.yellow,
                                    unselectedLabelColor:
                                        FlutterFlowTheme.of(context)
                                            .secondaryText,
                                    labelPadding: const EdgeInsets.all(16.0),
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .displaySmall,
                                    unselectedLabelStyle:
                                        FlutterFlowTheme.of(context)
                                            .displaySmall
                                            .override(
                                              font: GoogleFonts.interTight(
                                                fontWeight: FontWeight.normal,
                                              ),
                                              letterSpacing: 0.0,
                                            ),
                                    indicatorColor: Colors.yellow,
                                    indicatorWeight: 4.0,
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 12.0, 16.0, 12.0),
                                    tabs: const [
                                      Tab(text: 'Sign In'),
                                      Tab(text: 'Sign Up'),
                                    ],
                                    controller: _model.tabBarController,
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    controller: _model.tabBarController,
                                    children: [
                                      // Sign In Tab
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(12.0, 0.0, 12.0, 12.0),
                                        child: Form(
                                          key: _signInFormKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 12.0, 0.0, 24.0),
                                                child: Text(
                                                  'Let\'s get started by filling out the form below.',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelMedium,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 0.0, 0.0, 16.0),
                                                child: TextFormField(
                                                  controller: _model
                                                      .emailAddressTextController,
                                                  focusNode: _model
                                                      .emailAddressFocusNode,
                                                  onChanged: (_) {
                                                    if (_model.signInError !=
                                                        null) {
                                                      safeSetState(() => _model
                                                          .signInError = null);
                                                      _signInFormKey
                                                          .currentState
                                                          ?.validate();
                                                    }
                                                  },
                                                  autofocus: true,
                                                  autofillHints: const [
                                                    AutofillHints.email
                                                  ],
                                                  decoration: InputDecoration(
                                                    labelText: 'Email',
                                                    labelStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.yellow,
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.black,
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            24.0),
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium,
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  cursorColor: Colors.yellow,
                                                  validator: (val) {
                                                    if (val == null ||
                                                        val.isEmpty)
                                                      return 'Email is required';
                                                    if (_model.signInError !=
                                                            null &&
                                                        _model.signInError!
                                                            .contains('email'))
                                                      return _model.signInError;
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 0.0, 0.0, 16.0),
                                                child: TextFormField(
                                                  controller: _model
                                                      .passwordTextController,
                                                  focusNode:
                                                      _model.passwordFocusNode,
                                                  onChanged: (_) {
                                                    if (_model.signInError !=
                                                        null) {
                                                      safeSetState(() => _model
                                                          .signInError = null);
                                                      _signInFormKey
                                                          .currentState
                                                          ?.validate();
                                                    }
                                                  },
                                                  autofillHints: const [
                                                    AutofillHints.password
                                                  ],
                                                  obscureText: !_model
                                                      .passwordVisibility,
                                                  decoration: InputDecoration(
                                                    labelText: 'Password',
                                                    labelStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.yellow,
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.black,
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            24.0),
                                                    suffixIcon: InkWell(
                                                      onTap: () => safeSetState(
                                                          () => _model
                                                                  .passwordVisibility =
                                                              !_model
                                                                  .passwordVisibility),
                                                      child: Icon(
                                                        _model.passwordVisibility
                                                            ? Icons
                                                                .visibility_outlined
                                                            : Icons
                                                                .visibility_off_outlined,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium,
                                                  cursorColor: Colors.yellow,
                                                  validator: (val) {
                                                    if (val == null ||
                                                        val.isEmpty)
                                                      return 'Password is required';
                                                    if (_model.signInError !=
                                                            null &&
                                                        (_model.signInError!
                                                                .contains(
                                                                    'Password') ||
                                                            _model.signInError!
                                                                .contains(
                                                                    'credentials')))
                                                      return _model.signInError;
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    const AlignmentDirectional(
                                                        0.0, 0.0),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 0.0, 0.0, 16.0),
                                                  child: FFButtonWidget(
                                                    onPressed: () async {
                                                      if (!_signInFormKey
                                                          .currentState!
                                                          .validate()) return;
                                                      GoRouter.of(context)
                                                          .prepareAuthEvent();
                                                      try {
                                                        final user =
                                                            await authManager
                                                                .signInWithEmail(
                                                          context,
                                                          _model
                                                              .emailAddressTextController
                                                              .text,
                                                          _model
                                                              .passwordTextController
                                                              .text,
                                                        );
                                                        if (user == null)
                                                          return;
                                                        context.goNamedAuth(
                                                            HomePageWidget
                                                                .routeName,
                                                            context.mounted);
                                                      } on AuthException catch (e) {
                                                        safeSetState(() =>
                                                            _model.signInError =
                                                                e.message);
                                                        _signInFormKey
                                                            .currentState
                                                            ?.validate();
                                                        if (e.message.contains(
                                                                'email') ||
                                                            e.message.contains(
                                                                'user')) {
                                                          _model
                                                              .emailAddressFocusNode
                                                              ?.requestFocus();
                                                        } else {
                                                          _model
                                                              .passwordFocusNode
                                                              ?.requestFocus();
                                                        }
                                                      }
                                                    },
                                                    text: 'Sign In',
                                                    options: FFButtonOptions(
                                                      width: 230.0,
                                                      height: 52.0,
                                                      color: Colors.yellow,
                                                      textStyle: FlutterFlowTheme
                                                              .of(context)
                                                          .titleSmall
                                                          .override(
                                                              font: GoogleFonts
                                                                  .interTight(),
                                                              color:
                                                                  Colors.black),
                                                      elevation: 3.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    const AlignmentDirectional(
                                                        0.0, 0.0),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 0.0, 0.0, 16.0),
                                                  child: FFButtonWidget(
                                                    onPressed: () {},
                                                    text: 'Forgot Password',
                                                    options: FFButtonOptions(
                                                      width: 230.0,
                                                      height: 44.0,
                                                      color: Colors.black,
                                                      textStyle: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                              font: GoogleFonts
                                                                  .inter(),
                                                              color:
                                                                  Colors.white),
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.yellow,
                                                              width: 2.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ).animateOnPageLoad(animationsMap[
                                              'columnOnPageLoadAnimation1']!),
                                        ),
                                      ),
                                      // Sign Up Tab
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(12.0, 0.0, 12.0, 12.0),
                                        child: Form(
                                          key: _signUpFormKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 12.0, 0.0, 24.0),
                                                child: Text(
                                                  'Let\'s get started by filling out the form below.',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelMedium,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 0.0, 0.0, 16.0),
                                                child: TextFormField(
                                                  controller: _model
                                                      .emailAddressCreateTextController,
                                                  focusNode: _model
                                                      .emailAddressCreateFocusNode,
                                                  onChanged: (_) {
                                                    if (_model.signUpError !=
                                                        null) {
                                                      safeSetState(() => _model
                                                          .signUpError = null);
                                                      _signUpFormKey
                                                          .currentState
                                                          ?.validate();
                                                    }
                                                  },
                                                  autofillHints: const [
                                                    AutofillHints.email
                                                  ],
                                                  decoration: InputDecoration(
                                                    labelText: 'Email',
                                                    labelStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .alternate,
                                                          width: 2.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.yellow,
                                                          width: 2.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 2.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 2.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.black,
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            24.0),
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium,
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  cursorColor: Colors.yellow,
                                                  validator: (val) {
                                                    if (val == null ||
                                                        val.isEmpty)
                                                      return 'Email is required';
                                                    if (_model.signUpError !=
                                                            null &&
                                                        _model.signUpError!
                                                            .contains('email'))
                                                      return _model.signUpError;
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 0.0, 0.0, 16.0),
                                                child: TextFormField(
                                                  controller: _model
                                                      .passwordCreateTextController,
                                                  focusNode: _model
                                                      .passwordCreateFocusNode,
                                                  onChanged: (_) {
                                                    if (_model.signUpError !=
                                                        null) {
                                                      safeSetState(() => _model
                                                          .signUpError = null);
                                                      _signUpFormKey
                                                          .currentState
                                                          ?.validate();
                                                    }
                                                  },
                                                  autofillHints: const [
                                                    AutofillHints.password
                                                  ],
                                                  obscureText: !_model
                                                      .passwordCreateVisibility,
                                                  decoration: InputDecoration(
                                                    labelText: 'Password',
                                                    labelStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .alternate,
                                                          width: 2.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.yellow,
                                                          width: 2.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    suffixIcon: InkWell(
                                                      onTap: () => safeSetState(
                                                          () => _model
                                                                  .passwordCreateVisibility =
                                                              !_model
                                                                  .passwordCreateVisibility),
                                                      child: Icon(
                                                        _model.passwordCreateVisibility
                                                            ? Icons
                                                                .visibility_outlined
                                                            : Icons
                                                                .visibility_off_outlined,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.black,
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            24.0),
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium,
                                                  cursorColor: Colors.yellow,
                                                  validator: (val) {
                                                    if (val == null ||
                                                        val.isEmpty)
                                                      return 'Password is required';
                                                    if (_model.signUpError !=
                                                            null &&
                                                        _model.signUpError!
                                                            .contains(
                                                                'Password'))
                                                      return _model.signUpError;
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 0.0, 0.0, 16.0),
                                                child: TextFormField(
                                                  controller: _model
                                                      .passwordCreateConformTextController,
                                                  focusNode: _model
                                                      .passwordCreateConformFocusNode,
                                                  obscureText: !_model
                                                      .passwordCreateConformVisibility,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        'Confirm Password',
                                                    labelStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .alternate,
                                                          width: 2.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.yellow,
                                                          width: 2.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.0),
                                                    ),
                                                    suffixIcon: InkWell(
                                                      onTap: () => safeSetState(
                                                          () => _model
                                                                  .passwordCreateConformVisibility =
                                                              !_model
                                                                  .passwordCreateConformVisibility),
                                                      child: Icon(
                                                        _model.passwordCreateConformVisibility
                                                            ? Icons
                                                                .visibility_outlined
                                                            : Icons
                                                                .visibility_off_outlined,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.black,
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            24.0),
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium,
                                                  cursorColor: Colors.yellow,
                                                  validator: (val) {
                                                    if (val !=
                                                        _model
                                                            .passwordCreateTextController
                                                            .text)
                                                      return 'Passwords do not match';
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 16.0),
                                                child: CheckboxListTile(
                                                  value: _agreedToTerms,
                                                  onChanged: (val) =>
                                                      safeSetState(() =>
                                                          _agreedToTerms =
                                                              val ?? false),
                                                  title: Wrap(
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    children: [
                                                      Text('I agree to the ',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium),
                                                      InkWell(
                                                        onTap: () => Navigator
                                                                .of(context)
                                                            .push(MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const TermsOfServicePage())),
                                                        child: Text(
                                                            'Terms of Service',
                                                            style: GoogleFonts.inter(
                                                                color: Colors
                                                                    .yellow,
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                                fontSize: 14)),
                                                      ),
                                                      Text(' and ',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium),
                                                      InkWell(
                                                        onTap: () => Navigator
                                                                .of(context)
                                                            .push(MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const PrivacyPolicyPage())),
                                                        child: Text(
                                                            'Privacy Policy',
                                                            style: GoogleFonts.inter(
                                                                color: Colors
                                                                    .yellow,
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                                fontSize: 14)),
                                                      ),
                                                    ],
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  controlAffinity:
                                                      ListTileControlAffinity
                                                          .leading,
                                                  activeColor: Colors.yellow,
                                                  checkColor: Colors.white,
                                                  dense: true,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    const AlignmentDirectional(
                                                        0.0, 0.0),
                                                child: FFButtonWidget(
                                                  onPressed: () async {
                                                    if (!_agreedToTerms) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(const SnackBar(
                                                              content: Text(
                                                                  'You must agree to the Terms to continue.'),
                                                              backgroundColor:
                                                                  Colors.red));
                                                      return;
                                                    }
                                                    if (!_signUpFormKey
                                                        .currentState!
                                                        .validate()) return;
                                                    GoRouter.of(context)
                                                        .prepareAuthEvent();
                                                    try {
                                                      final user = await authManager
                                                          .createAccountWithEmail(
                                                        context,
                                                        _model
                                                            .emailAddressCreateTextController
                                                            .text,
                                                        _model
                                                            .passwordCreateTextController
                                                            .text,
                                                      );
                                                      if (user == null) return;
                                                      await UsersTable()
                                                          .insert({
                                                        'email': _model
                                                            .emailAddressCreateTextController
                                                            .text,
                                                        'password': _model
                                                            .passwordCreateTextController
                                                            .text,
                                                      });
                                                      context.pushNamedAuth(
                                                          ProfileCreateCustomWidget
                                                              .routeName,
                                                          context.mounted);
                                                    } on AuthException catch (e) {
                                                      safeSetState(() =>
                                                          _model.signUpError =
                                                              e.message);
                                                      _signUpFormKey
                                                          .currentState
                                                          ?.validate();
                                                      if (e.message.contains(
                                                              'email') ||
                                                          e.message.contains(
                                                              'user')) {
                                                        _model
                                                            .emailAddressCreateFocusNode
                                                            ?.requestFocus();
                                                      } else {
                                                        _model
                                                            .passwordCreateFocusNode
                                                            ?.requestFocus();
                                                      }
                                                    }
                                                  },
                                                  text: 'Create Account',
                                                  options: FFButtonOptions(
                                                    width: 230.0,
                                                    height: 52.0,
                                                    color: Colors.yellow,
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                            font: GoogleFonts
                                                                .interTight(),
                                                            color:
                                                                Colors.black),
                                                    elevation: 3.0,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40.0),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ).animateOnPageLoad(animationsMap[
                                              'columnOnPageLoadAnimation2']!),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24.0),
                                  child: FFButtonWidget(
                                    onPressed: () => context.goNamed(
                                        HomePageWidget.routeName),
                                    text: 'Continue as Guest',
                                    options: FFButtonOptions(
                                      width: 230.0,
                                      height: 44.0,
                                      color: Colors.transparent,
                                      textStyle: GoogleFonts.inter(
                                        color: Colors.yellow,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      borderSide: BorderSide.none,
                                      elevation: 0.0,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (responsiveVisibility(
                  context: context, phone: false, tablet: false))
                Expanded(
                  flex: 6,
                  child: Container(
                    width: 100.0,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                          'https://images.unsplash.com/photo-1508385082359-f38ae991e8f2?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1374&q=80',
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

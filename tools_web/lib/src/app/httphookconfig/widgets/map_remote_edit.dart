// Copyright 2021 Kwai, Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:k_debug_tools_web/src/app/httphook/http_models.dart';
import 'package:k_debug_tools_web/src/bloc_provider.dart';
import 'package:k_debug_tools_web/src/theme.dart';
import 'package:k_debug_tools_web/src/widgets/common_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../app_window_bloc.dart';
import '../hook_config_bloc.dart';
import '../hook_config_models.dart';

class HookConfigMapRemote extends StatefulWidget {
  final HttpArchive httpArchive;
  final HookConfig hookConfig;

  const HookConfigMapRemote({Key key, this.httpArchive, this.hookConfig})
      : super(key: key);

  @override
  _HookConfigMapRemoteState createState() => _HookConfigMapRemoteState();
}

class _HookConfigMapRemoteState extends State<HookConfigMapRemote> {
  AppWindowBloc _windowBloc;
  HookConfigBloc _hookConfigBloc;
  TextEditingController _uriEditingController;
  TextEditingController _remoteUriEditingController;

  @override
  void initState() {
    _windowBloc = BlocProvider.of<AppWindowBloc>(context).first;
    _hookConfigBloc = BlocProvider.of<HookConfigBloc>(context).first;
    _uriEditingController = TextEditingController();
    _remoteUriEditingController = TextEditingController();
    //read original values
    if (widget.httpArchive != null) {
      _uriEditingController.text = widget.httpArchive.url;
    } else if (widget.hookConfig != null) {
      _uriEditingController.text = widget.hookConfig.uriPattern;
      _remoteUriEditingController.text = widget.hookConfig.mapRemoteUrl;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(densePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //顶部菜单 action
          _buildActionWidget(),
          SizedBox(height: denseSpacing),
          Expanded(
            child: _buildContentWidget(),
          )
        ],
      ),
    );
  }

  ///action区域
  Widget _buildActionWidget() {
    return Container(
      child: Row(
        children: <Widget>[
          ActionOutlinedButton(
            'Save',
            icon: Icons.save_rounded,
            enable: true,
            onTap: () {
              if (_uriEditingController.text.isEmpty ||
                  _remoteUriEditingController.text.isEmpty) {
                _windowBloc.toast('Url无效');
                return;
              }
              HookConfig hookConfig = widget.hookConfig ?? HookConfig();
              hookConfig.enable = true;
              hookConfig.mapRemote = true;
              hookConfig.mapRemoteUrl = _remoteUriEditingController.text;
              hookConfig.uriPattern = _uriEditingController.text;
              _hookConfigBloc.save(hookConfig).then((value) {
                _windowBloc.showDialog(
                    msg: AppLocalizations.of(context).success,
                    barrierDismissible: false,
                    actions: [
                      DialogAction(
                          text: AppLocalizations.of(context).ok,
                          handler: (ctrl) {
                            ctrl.dismiss();
                            _windowBloc.close();
                          },
                          isPositive: true)
                    ]);
              }).catchError((e) {
                _windowBloc.toast(AppLocalizations.of(context).requestError(e));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget() {
    ThemeData theme = Theme.of(context);
    return DefaultTextStyle(
      style: theme.textTheme.bodyText2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Map from url'),
          SizedBox(height: densePadding),
          Container(
            padding: EdgeInsets.all(densePadding),
            decoration:
            BoxDecoration(border: Border.all(color: theme.focusColor)),
            child: TextField(
              expands: false,
              textAlign: TextAlign.start,
              showCursor: true,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              style: TextStyle(fontSize: 14),
              decoration: null,
              controller: _uriEditingController,
            ),
          ),
          SizedBox(height: denseSpacing),
          Text('Map to url'),
          SizedBox(height: densePadding),
          Expanded(
              child: Scrollbar(
            child: Container(
              padding: EdgeInsets.all(densePadding),
              decoration:
              BoxDecoration(border: Border.all(color: theme.focusColor)),
              child: TextField(
                expands: false,
                textAlign: TextAlign.start,
                showCursor: true,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                style: TextStyle(fontSize: 14),
                decoration: null,
                controller: _remoteUriEditingController,
              ),
            ),
          )),
          SizedBox(height: denseSpacing),
          Text('url支持通配符 ? * 进行匹配'), //todo 一些操作说明
        ],
      ),
    );
  }
}

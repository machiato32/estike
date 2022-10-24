import 'package:estike/config.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OwnAboutDialog extends StatelessWidget {
  const OwnAboutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ezt az alkalmazást a 2021/22-es tanévben Katkó Dominik (katkodominik@gmail.com)' +
                  ' és Szajbély Sámuel (s.szajbely@gmail.com) írta. A gépen futó program kódja megtalállható a' +
                  ' https://github.com/machiato32/estike linken.' +
                  ' A szerveroldali rész kódja nem nyilvános, jelenleg a program a ' +
                  APP_URL +
                  ' oldalról van hostolva. A program jelen állapotában Windowson, Linuxon és Androidon tud futni.' +
                  ' Ha bármilyen kérdésed lenne, ' +
                  'valami nem működne vagy csak beszélgetnél, akkor írj a fenti e-mail címek egyikére.',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            TextButton(
              onPressed: () {
                launchUrlString('https://github.com/machiato32/estike',
                    mode: LaunchMode.externalApplication);
              },
              child: Text('GitHub'),
            ),
            TextButton(
              onPressed: () {
                launchUrlString(
                    'mailto:s.szajbely@gmail.com?&cc=katkodominik@gmail.com');
              },
              child: Text('E-mail nekünk'),
            ),
          ],
        ),
      ),
    );
  }
}

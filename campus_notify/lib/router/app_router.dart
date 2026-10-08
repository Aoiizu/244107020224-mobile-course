import 'package:go_router/go_router.dart';
import '../data/app_deps.dart';
import '../pages/announcement_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import 'route_logic.dart';

GoRouter buildRouter(AppDeps deps) => GoRouter(
      initialLocation: '/',
      refreshListenable: deps.session, // re-run guard on login/logout
      redirect: (context, state) => authRedirect(
        loggedIn: deps.session.isAuthenticated,
        location: state.uri.toString(),
      ),
      routes: [
        GoRoute(path: '/login', builder: (_, __) => LoginPage(deps: deps)),
        GoRoute(
          path: '/',
          builder: (_, __) => HomePage(deps: deps),
          routes: [
            // child route => back button returns to Home after a deep link
            GoRoute(
              path: 'announcement/:id',
              builder: (_, s) =>
                  AnnouncementPage(deps: deps, id: s.pathParameters['id']!),
            ),
          ],
        ),
      ],
    );

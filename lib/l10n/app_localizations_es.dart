// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Calendario';

  @override
  String get welcomeTitle => 'Tu tiempo,\nsin ruido.';

  @override
  String get welcomeBody =>
      'Todos tus calendarios en un solo lugar. Sincronización con Google, festivos y calendarios compartidos con tus seres queridos.';

  @override
  String get connectGoogle => 'Conectar con Google';

  @override
  String get continueWithout => 'Continuar sin cuenta';

  @override
  String get back => 'Atrás';

  @override
  String get connectTitle => 'Conectar Google Calendar';

  @override
  String get weAskFor => 'Pediremos acceso a';

  @override
  String get accessEvents => 'Eventos — leer y editar';

  @override
  String get accessCalendars => 'Tu lista de calendarios';

  @override
  String get accessInvites => 'Respuestas a invitaciones';

  @override
  String get accessEmail => 'El correo de tu cuenta';

  @override
  String get noAccessTo => 'Sin acceso a';

  @override
  String get noAccessFiles => 'Correo, Drive y Fotos';

  @override
  String get noAccessContacts => 'Contactos y otras apps';

  @override
  String get signInGoogle => 'Iniciar sesión con Google';

  @override
  String signInFailed(String error) {
    return 'Error al iniciar sesión: $error';
  }

  @override
  String get noClientId =>
      'Esta versión no tiene el ID de cliente de Google. Consulta docs/GOOGLE.md.';

  @override
  String get chooseTitle => 'Elige calendarios';

  @override
  String get calendars => 'Calendarios';

  @override
  String get sharedWithYou => 'Compartidos contigo';

  @override
  String get suggested => 'Sugeridos';

  @override
  String syncN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Sincronizar $n calendarios',
      one: 'Sincronizar 1 calendario',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Listo';

  @override
  String get year => 'Año';

  @override
  String get month => 'Mes';

  @override
  String get week => 'Semana';

  @override
  String get day => 'Día';

  @override
  String weekN(int n) {
    return 'Semana $n';
  }

  @override
  String eventsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n eventos',
      one: '1 evento',
    );
    return '$_temp0';
  }

  @override
  String moreN(int n) {
    return '$n más';
  }

  @override
  String inMin(int n) {
    return 'En $n min';
  }

  @override
  String get today => 'Hoy';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get next => 'Siguiente';

  @override
  String get allDay => 'Todo el día';

  @override
  String get noEvents => 'Sin eventos';

  @override
  String get weekdays => 'LU,MA,MI,JU,VI,SÁ,DO';

  @override
  String get previous => 'Anterior';

  @override
  String get following => 'Siguiente';

  @override
  String get newEvent => 'Nuevo evento';

  @override
  String get eventName => 'Nombre del evento';

  @override
  String get save => 'Guardar';

  @override
  String get closeNoSave => 'Cerrar sin guardar';

  @override
  String get start => 'Inicio';

  @override
  String get end => 'Fin';

  @override
  String get calendar => 'Calendario';

  @override
  String get place => 'Ubicación';

  @override
  String get notes => 'Notas';

  @override
  String get add => 'Añadir';

  @override
  String get reminder => 'Recordatorio';

  @override
  String get none => 'Ninguno';

  @override
  String minBefore(int n) {
    return '$n min antes';
  }

  @override
  String hoursBefore(int n) {
    return '$n h antes';
  }

  @override
  String daysBefore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n días antes',
      one: '1 día antes',
    );
    return '$_temp0';
  }

  @override
  String get guests => 'Invitados';

  @override
  String get youOrganize => 'Tú organizas';

  @override
  String get rsvpYes => 'Sí';

  @override
  String get rsvpMaybe => 'Quizás';

  @override
  String get rsvpNo => 'No';

  @override
  String get rsvpWaiting => 'Pendiente';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deleteTitle => '¿Eliminar el evento?';

  @override
  String repeats(String title) {
    return '$title se repite.';
  }

  @override
  String get onlyThis => 'Solo este';

  @override
  String get thisAndFollowing => 'Este y los siguientes';

  @override
  String get allOccurrences => 'Todos';

  @override
  String get notifyGuests => 'Avisar a los invitados';

  @override
  String get endBeforeStart => 'El fin debe ser posterior al inicio.';

  @override
  String failed(String error) {
    return 'Error: $error';
  }

  @override
  String get syncing => 'Sincronizando';

  @override
  String eventsFrom(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'eventos de $n calendarios',
      one: 'eventos de 1 calendario',
    );
    return '$_temp0';
  }

  @override
  String aboutSecondsLeft(int n) {
    return 'Quedan unos $n s';
  }

  @override
  String get statusDone => 'Listo';

  @override
  String get statusRunning => 'En curso';

  @override
  String get statusQueued => 'En cola';

  @override
  String get statusFailed => 'Error';

  @override
  String get runInBackground => 'Seguir en segundo plano';

  @override
  String get search => 'Buscar';

  @override
  String get searchHint => 'Buscar eventos, personas, lugares';

  @override
  String get clear => 'Borrar';

  @override
  String get filterAll => 'Todo';

  @override
  String get withGuests => 'Con invitados';

  @override
  String get upcoming => 'Próximos';

  @override
  String get past => 'Pasados';

  @override
  String get noResults => 'No se encontró nada';

  @override
  String everyDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Cada $n días',
      one: 'Cada día',
    );
    return '$_temp0';
  }

  @override
  String everyWeeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Cada $n semanas',
      one: 'Cada semana',
    );
    return '$_temp0';
  }

  @override
  String everyMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Cada $n meses',
      one: 'Cada mes',
    );
    return '$_temp0';
  }

  @override
  String everyYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Cada $n años',
      one: 'Cada año',
    );
    return '$_temp0';
  }

  @override
  String get weekdaysOn =>
      'el lunes,el martes,el miércoles,el jueves,el viernes,el sábado,el domingo';

  @override
  String get weekdaysAcc =>
      'lunes,martes,miércoles,jueves,viernes,sábado,domingo';

  @override
  String get and => 'y';

  @override
  String ruleUntil(String date) {
    return ', hasta el $date';
  }

  @override
  String ruleCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: ', $n veces',
      one: ', una vez',
    );
    return '$_temp0';
  }

  @override
  String get ruleForever => ', sin fin';

  @override
  String get repeat => 'Repetir';

  @override
  String get never => 'Nunca';

  @override
  String get custom => 'Personalizado';

  @override
  String get timeZone => 'Zona horaria';

  @override
  String get invite => 'Invitar';

  @override
  String calendarDefault(String value) {
    return 'Predeterminado ($value)';
  }

  @override
  String get atStart => 'Al inicio';

  @override
  String get every => 'Cada';

  @override
  String get less => 'Menos';

  @override
  String get more => 'Más';

  @override
  String get unitDays => 'Días';

  @override
  String get unitWeeks => 'Semanas';

  @override
  String get unitMonths => 'Meses';

  @override
  String get unitYears => 'Años';

  @override
  String get onDays => 'Los días';

  @override
  String get ends => 'Termina';

  @override
  String get onDate => 'En la fecha';

  @override
  String get after => 'Después de';

  @override
  String afterTimes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n veces',
      one: '1 vez',
    );
    return '$_temp0';
  }

  @override
  String get summary => 'Resumen';

  @override
  String get event => 'Evento';

  @override
  String get inviteTitle => 'Invitar';

  @override
  String get send => 'Enviar';

  @override
  String get nameOrEmail => 'Nombre o correo electrónico';

  @override
  String get selected => 'Seleccionados';

  @override
  String get suggestions => 'Sugerencias';

  @override
  String get guestsCan => 'Los invitados pueden';

  @override
  String get canInvite => 'Invitar a otros';

  @override
  String get canModify => 'Editar el evento';

  @override
  String get canSee => 'Ver la lista de invitados';

  @override
  String get inviteNote =>
      'Enviaremos la invitación por correo desde tu cuenta de Google.';

  @override
  String get inviteMore => 'Invitar a más personas';

  @override
  String get shareEvent => 'Compartir evento';

  @override
  String invitationFrom(String name) {
    return 'Invitación de $name';
  }

  @override
  String get organizerLabel => 'Organizador';

  @override
  String get conflict => 'Conflicto';

  @override
  String get nothingPlanned => 'Nada planeado.';

  @override
  String get addEvent => 'Añadir evento';

  @override
  String get holiday => 'Festivo';

  @override
  String get syncLabel => 'Sincronización';

  @override
  String get conflictTitle => 'Cambios en conflicto';

  @override
  String conflictBody(String title) {
    return '$title se cambió en este teléfono y en Google. Elige qué versión conservar.';
  }

  @override
  String get thisPhone => 'Este teléfono';

  @override
  String changedAt(String time) {
    return 'Cambiado $time';
  }

  @override
  String get time => 'Hora';

  @override
  String get titleLabel => 'Título';

  @override
  String get keepBoth => 'Conservar ambos';

  @override
  String get useSelected => 'Usar lo elegido';

  @override
  String get visibility => 'Visibilidad';

  @override
  String get mineGoogle => 'Míos · Google';

  @override
  String get sharedWithMe => 'Compartidos conmigo';

  @override
  String get subscriptions => 'Suscripciones';

  @override
  String get addCalendar => 'Añadir calendario';

  @override
  String get roleOwner => 'Propietario';

  @override
  String get roleWriter => 'Editar';

  @override
  String get roleReader => 'Ver';

  @override
  String get roleFreeBusy => 'Solo ocupado';

  @override
  String shareCalendar(String name) {
    return 'Compartir el calendario $name';
  }

  @override
  String get newCalendar => 'Nuevo calendario';

  @override
  String get newCalendarHint => 'En tu cuenta de Google';

  @override
  String get holidaysAndDaysOff => 'Festivos y días libres';

  @override
  String get holidaysHint => 'Festivos nacionales y religiosos';

  @override
  String get googleAccount => 'Cuenta de Google';

  @override
  String get googleAccountHint => 'Iniciar sesión y sincronizar';

  @override
  String get calendarName => 'Nombre del calendario';

  @override
  String get holidays => 'Festivos';

  @override
  String get country => 'País';

  @override
  String get addCountry => '+ Añadir país';

  @override
  String holidaysInYear(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n festivos este año',
      one: '1 festivo este año',
    );
    return '$_temp0';
  }

  @override
  String get nearest => 'Próximamente';

  @override
  String get shareTitle => 'Compartir';

  @override
  String calendarNamed(String name) {
    return 'Calendario $name';
  }

  @override
  String get peopleWithAccess => 'Personas con acceso';

  @override
  String get you => 'Tú';

  @override
  String get addPerson => 'Añadir persona';

  @override
  String get newPeopleAccess => 'Acceso para personas nuevas';

  @override
  String get freeBusyHint =>
      'Solo ocupado muestra cuándo estás ocupado, sin los nombres de los eventos.';

  @override
  String get link => 'Enlace';

  @override
  String get linkAccess => 'Acceso con enlace';

  @override
  String get copyLink => 'Copiar enlace';

  @override
  String get off => 'Desactivado';

  @override
  String get linkCopied => 'Enlace copiado';

  @override
  String get removeAccess => 'Quitar acceso';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String sharesWithYou(String name) {
    return '$name comparte un calendario contigo';
  }

  @override
  String get yourAccess => 'Tu acceso';

  @override
  String get marker => 'Marcador';

  @override
  String get shapeNames =>
      'Punto,Cuadrado,Mitad,Rombo,Anillo,Discontinuo,Triángulo,Triángulo invertido,Cuadrado vacío,Rombo vacío,Más,Cruz,Estrella,Hexágono,Corazón,Diana,Cuadrado con punto,Porción,Diagonal,Barra,Pilar,Dos puntos,Triángulo vacío,Mitad superior';

  @override
  String get showInViews => 'Mostrar en las vistas';

  @override
  String get otherWay => 'Al revés';

  @override
  String get shareYours => 'Compartir tu calendario también';

  @override
  String get choose => 'Elegir';

  @override
  String get shared => 'Compartido';

  @override
  String get reject => 'Quitar';

  @override
  String get settings => 'Ajustes';

  @override
  String get upToDate => 'Al día';

  @override
  String get offline => 'Sin conexión';

  @override
  String get appearance => 'Apariencia';

  @override
  String get notificationsGlyph => 'Notificaciones';

  @override
  String get calendarsSharing => 'Calendarios y uso compartido';

  @override
  String get dataPrivacy => 'Datos y privacidad';

  @override
  String get help => 'Ayuda';

  @override
  String get about => 'Información';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get theme => 'Tema';

  @override
  String get firstDay => 'Primer día de la semana';

  @override
  String get timeFormat => 'Formato de hora';

  @override
  String get weekNumbers => 'Números de semana';

  @override
  String get showWeekends => 'Mostrar fines de semana';

  @override
  String get declinedInvites => 'Invitaciones rechazadas';

  @override
  String get style => 'Estilo';

  @override
  String get dotDigits => 'Cifras de puntos';

  @override
  String get dimPast => 'Atenuar lo pasado';

  @override
  String get accounts => 'Cuentas';

  @override
  String get lastSync => 'Última sincronización';

  @override
  String calendarsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n calendarios',
      one: '1 calendario',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get active => 'Activa';

  @override
  String get addAccount => 'Añadir cuenta';

  @override
  String get automatic => 'Automáticamente';

  @override
  String get frequency => 'Frecuencia';

  @override
  String everyMinutes(int n) {
    return 'Cada $n min';
  }

  @override
  String get disconnectGoogle => 'Desconectar la cuenta de Google';

  @override
  String get disconnectBody =>
      'Los calendarios y ajustes se eliminan de este teléfono. En Google no cambia nada.';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get privacy => 'Privacidad';

  @override
  String get hideOnLockScreen => 'Ocultar detalles en la pantalla de bloqueo';

  @override
  String get device => 'Dispositivo';

  @override
  String get clearData => 'Borrar datos de este dispositivo';

  @override
  String get clearDataBody =>
      'Los calendarios, la caché y los ajustes se eliminan de este teléfono y se cierra la sesión.';

  @override
  String get googleUntouched => 'Tus eventos en Google no cambian.';

  @override
  String get searchHelp => 'Buscar en la ayuda';

  @override
  String get faq => 'Preguntas frecuentes';

  @override
  String get contact => 'Contacto';

  @override
  String get aboutApp => 'Sobre la app';

  @override
  String readTime(String topic) {
    return '$topic · 1 min de lectura';
  }

  @override
  String get tip => 'Consejo';

  @override
  String openScreen(String name) {
    return 'Abrir $name';
  }

  @override
  String get devVersion => 'Versión de desarrollo';

  @override
  String get stableVersion => 'Versión estable';

  @override
  String get build => 'Compilación';

  @override
  String get system => 'Sistema';

  @override
  String get legal => 'Legal';

  @override
  String get licenses => 'Licencias de código abierto';

  @override
  String get typefaces => 'Tipografías';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get defaultLabel => 'Predeterminado';

  @override
  String get allDayEvents => 'Todo el día';

  @override
  String dayBeforeAt(String time) {
    return '$time el día antes';
  }

  @override
  String get dailySummary => 'Resumen diario';

  @override
  String everyDayAt(String time) {
    return 'Cada día a las $time';
  }

  @override
  String get invitations => 'Invitaciones';

  @override
  String get newInvitations => 'Invitaciones nuevas';

  @override
  String get sharedChanges => 'Cambios en calendarios compartidos';

  @override
  String summaryTitle(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Hoy: $n eventos',
      one: 'Hoy: 1 evento',
    );
    return '$_temp0';
  }

  @override
  String invitesYou(String name, String title) {
    return '$name te invita: $title';
  }

  @override
  String changesIn(String name) {
    return 'Cambios: $name';
  }

  @override
  String get sharedCalendars => 'Calendarios compartidos';

  @override
  String get snooze => 'Posponer 5 min';

  @override
  String get details => 'Detalles';

  @override
  String get off2 => 'Desactivado';

  @override
  String get personal => 'Personal';

  @override
  String get customReminder => 'Recordatorio personalizado';

  @override
  String get unitMinutes => 'Minutos';

  @override
  String get unitHours => 'Horas';

  @override
  String get reminderLimit => 'Hasta 4 semanas antes.';

  @override
  String clashesWith(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'coincide con $n eventos',
      one: 'coincide con 1 evento',
    );
    return '$_temp0';
  }

  @override
  String get crashTitle => 'La app se cerró inesperadamente';

  @override
  String get crashBody => 'Copia este informe y envíalo al desarrollador.';

  @override
  String get close => 'Cerrar';

  @override
  String get copy => 'Copiar';

  @override
  String get saveRepeating => 'Guardar cambios en un evento periódico';

  @override
  String get weekNumbersHint =>
      'Número de semana delante de cada fila de la vista mensual.';

  @override
  String get showWeekendsHint =>
      'Desactivado: las vistas de mes y semana muestran solo de lunes a viernes.';

  @override
  String get declinedHint =>
      'Mostrar en las vistas las invitaciones que rechazaste.';

  @override
  String get dimPastHint => 'Los eventos y días que ya pasaron se ven en gris.';

  @override
  String get inBackground => 'En segundo plano';

  @override
  String get notYet => 'Todavía no';

  @override
  String get check => 'Comprobar';

  @override
  String get testBackgroundHint =>
      'Cierra la app durante 1–2 minutos y vuelve aquí.';

  @override
  String clashesN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n conflictos',
      one: '1 conflicto',
    );
    return '$_temp0';
  }

  @override
  String inH(int h) {
    return 'En $h h';
  }

  @override
  String inHM(int h, int m) {
    return 'En $h h $m min';
  }

  @override
  String get dayOff => 'Día libre';

  @override
  String hoursFree(int h) {
    return '$h h libres';
  }

  @override
  String get wifiOnly => 'Solo con Wi-Fi';

  @override
  String get wifiOnlyHint =>
      'La sincronización automática y en segundo plano espera al Wi-Fi. Deslizar hacia abajo siempre sincroniza.';

  @override
  String get importFile => 'Importar archivo';

  @override
  String get importFileHint => 'Archivo .ics del teléfono';

  @override
  String get exportAll => 'Exportar todo';

  @override
  String get importExport => 'Importar y exportar';

  @override
  String importTo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Importar $n eventos a',
      one: 'Importar 1 evento a',
    );
    return '$_temp0';
  }

  @override
  String importing(int done, int n) {
    return 'Importando $done de $n';
  }

  @override
  String importedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n eventos importados',
      one: '1 evento importado',
    );
    return '$_temp0';
  }

  @override
  String failedN(int n) {
    return '$n con error';
  }

  @override
  String get icsEmpty => 'No hay eventos en este archivo';

  @override
  String get exporting => 'Exportando…';

  @override
  String get fileSaved => 'Archivo guardado';

  @override
  String get notSignedIn => 'Sin iniciar sesión';

  @override
  String get removeCountry => 'Quitar país';

  @override
  String get subscribeUrl => 'Suscribirse a una dirección';

  @override
  String get subscribeUrlHint => 'Enlace .ics o webcal://';

  @override
  String get subscribe => 'Suscribirse';

  @override
  String get subscribeNote =>
      'Se actualiza cada hora. El calendario es de solo lectura.';

  @override
  String get subscribing => 'Suscribiendo…';

  @override
  String subscribed(String name) {
    return 'Suscrito: $name';
  }

  @override
  String get unsubscribe => 'Cancelar suscripción';

  @override
  String unsubscribeBody(String name) {
    return 'El calendario $name y sus eventos se eliminan de Google. Puedes volver a suscribirte más tarde.';
  }

  @override
  String get notIcs => 'Esta dirección no es un calendario .ics';

  @override
  String get deleteCalendar => 'Eliminar calendario';

  @override
  String deleteCalendarBody(String name) {
    return 'El calendario $name y todos sus eventos se eliminan de Google para todas las personas con las que se comparte. No se puede deshacer.';
  }

  @override
  String get freeNow => 'Libre';

  @override
  String ongoingUntil(String time) {
    return 'Ahora · hasta $time';
  }

  @override
  String get appLock => 'Bloqueo de la app';

  @override
  String get appLockHint =>
      'Pide tu huella, cara o código de bloqueo al abrir la app y tras un minuto fuera.';

  @override
  String get appLocked => 'Calendario bloqueado';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get unlockReason => 'Desbloquear Calendario';

  @override
  String get appLockNoScreenLock =>
      'Primero configura un bloqueo de pantalla en el teléfono.';

  @override
  String get glyphInterface => 'Glyph Interface';

  @override
  String get glyphLight => 'Luz con los recordatorios';

  @override
  String get glyphPattern => 'Patrón de luz';

  @override
  String get glyphCountdown => 'Cuenta atrás al evento';

  @override
  String get glyphPulse => 'Pulso';

  @override
  String get glyphBlink => 'Parpadeo';

  @override
  String get glyphSteady => 'Fija';

  @override
  String get glyphGlass => 'Vaso';

  @override
  String get glyphClock => 'Reloj';

  @override
  String get myCalendar => 'Mi calendario';

  @override
  String get onDevice => 'En este dispositivo';

  @override
  String get onlyThisPhone => 'Solo este teléfono';

  @override
  String get newCalendarLocalHint => 'Solo en este teléfono';

  @override
  String get onPhone => 'En el teléfono';

  @override
  String get chooseLanguage => 'Elige un idioma';

  @override
  String get phoneLanguage => 'Idioma del teléfono';

  @override
  String get continueBtn => 'Continuar';

  @override
  String get language => 'Idioma';

  @override
  String get newVersion => 'Nueva versión';

  @override
  String currentVersion(String version) {
    return 'Ahora $version';
  }

  @override
  String get whatsNew => 'Novedades';

  @override
  String get downloadInstall => 'Descargar e instalar';

  @override
  String get later => 'Más tarde';

  @override
  String newVersionN(String version) {
    return 'Nueva versión $version';
  }

  @override
  String get tapToSee => 'Toca para verla';

  @override
  String get updates => 'Actualizaciones';
}

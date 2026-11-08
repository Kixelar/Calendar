// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Calendário';

  @override
  String get welcomeTitle => 'Seu tempo,\nsem ruído.';

  @override
  String get welcomeBody =>
      'Todas as suas agendas em um só lugar. Sincronização com o Google, feriados e agendas compartilhadas com quem você ama.';

  @override
  String get connectGoogle => 'Conectar ao Google';

  @override
  String get continueWithout => 'Continuar sem conta';

  @override
  String get back => 'Voltar';

  @override
  String get connectTitle => 'Conectar o Google Agenda';

  @override
  String get weAskFor => 'Vamos pedir acesso a';

  @override
  String get accessEvents => 'Eventos — ler e editar';

  @override
  String get accessCalendars => 'Sua lista de agendas';

  @override
  String get accessInvites => 'Respostas a convites';

  @override
  String get accessEmail => 'O e-mail da conta';

  @override
  String get noAccessTo => 'Sem acesso a';

  @override
  String get noAccessFiles => 'E-mail, Drive e Fotos';

  @override
  String get noAccessContacts => 'Contatos e outros apps';

  @override
  String get signInGoogle => 'Entrar com o Google';

  @override
  String signInFailed(String error) {
    return 'Falha ao entrar: $error';
  }

  @override
  String get noClientId =>
      'Esta versão não tem o ID de cliente do Google. Veja docs/GOOGLE.md.';

  @override
  String get chooseTitle => 'Escolha as agendas';

  @override
  String get calendars => 'Agendas';

  @override
  String get sharedWithYou => 'Compartilhadas com você';

  @override
  String get suggested => 'Sugestões';

  @override
  String syncN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Sincronizar $n agendas',
      one: 'Sincronizar 1 agenda',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Concluído';

  @override
  String get year => 'Ano';

  @override
  String get month => 'Mês';

  @override
  String get week => 'Semana';

  @override
  String get day => 'Dia';

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
    return 'Mais $n';
  }

  @override
  String inMin(int n) {
    return 'Em $n min';
  }

  @override
  String get today => 'Hoje';

  @override
  String get tomorrow => 'Amanhã';

  @override
  String get next => 'A seguir';

  @override
  String get allDay => 'Dia inteiro';

  @override
  String get noEvents => 'Nenhum evento';

  @override
  String get weekdays => 'SEG,TER,QUA,QUI,SEX,SÁB,DOM';

  @override
  String get previous => 'Anterior';

  @override
  String get following => 'Próximo';

  @override
  String get newEvent => 'Novo evento';

  @override
  String get eventName => 'Nome do evento';

  @override
  String get save => 'Salvar';

  @override
  String get closeNoSave => 'Fechar sem salvar';

  @override
  String get start => 'Início';

  @override
  String get end => 'Fim';

  @override
  String get calendar => 'Agenda';

  @override
  String get place => 'Local';

  @override
  String get notes => 'Notas';

  @override
  String get add => 'Adicionar';

  @override
  String get reminder => 'Lembrete';

  @override
  String get none => 'Nenhum';

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
      other: '$n dias antes',
      one: '1 dia antes',
    );
    return '$_temp0';
  }

  @override
  String get guests => 'Convidados';

  @override
  String get youOrganize => 'Você organiza';

  @override
  String get rsvpYes => 'Sim';

  @override
  String get rsvpMaybe => 'Talvez';

  @override
  String get rsvpNo => 'Não';

  @override
  String get rsvpWaiting => 'Aguardando';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Excluir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deleteTitle => 'Excluir o evento?';

  @override
  String repeats(String title) {
    return '$title se repete.';
  }

  @override
  String get onlyThis => 'Só este';

  @override
  String get thisAndFollowing => 'Este e os seguintes';

  @override
  String get allOccurrences => 'Todos';

  @override
  String get notifyGuests => 'Avisar os convidados';

  @override
  String get endBeforeStart => 'O fim deve ser depois do início.';

  @override
  String failed(String error) {
    return 'Falhou: $error';
  }

  @override
  String get syncing => 'Sincronizando';

  @override
  String eventsFrom(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'eventos de $n agendas',
      one: 'eventos de 1 agenda',
    );
    return '$_temp0';
  }

  @override
  String aboutSecondsLeft(int n) {
    return 'Faltam cerca de $n s';
  }

  @override
  String get statusDone => 'Concluído';

  @override
  String get statusRunning => 'Em andamento';

  @override
  String get statusQueued => 'Na fila';

  @override
  String get statusFailed => 'Falhou';

  @override
  String get runInBackground => 'Continuar em segundo plano';

  @override
  String get search => 'Pesquisar';

  @override
  String get searchHint => 'Pesquisar eventos, pessoas, locais';

  @override
  String get clear => 'Limpar';

  @override
  String get filterAll => 'Tudo';

  @override
  String get withGuests => 'Com convidados';

  @override
  String get upcoming => 'Próximos';

  @override
  String get past => 'Passados';

  @override
  String get noResults => 'Nada encontrado';

  @override
  String everyDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'A cada $n dias',
      one: 'Todo dia',
    );
    return '$_temp0';
  }

  @override
  String everyWeeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'A cada $n semanas',
      one: 'Toda semana',
    );
    return '$_temp0';
  }

  @override
  String everyMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'A cada $n meses',
      one: 'Todo mês',
    );
    return '$_temp0';
  }

  @override
  String everyYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'A cada $n anos',
      one: 'Todo ano',
    );
    return '$_temp0';
  }

  @override
  String get weekdaysOn =>
      'na segunda-feira,na terça-feira,na quarta-feira,na quinta-feira,na sexta-feira,no sábado,no domingo';

  @override
  String get weekdaysAcc =>
      'segunda-feira,terça-feira,quarta-feira,quinta-feira,sexta-feira,sábado,domingo';

  @override
  String get and => 'e';

  @override
  String ruleUntil(String date) {
    return ', até $date';
  }

  @override
  String ruleCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: ', $n vezes',
      one: ', uma vez',
    );
    return '$_temp0';
  }

  @override
  String get ruleForever => ', sem fim';

  @override
  String get repeat => 'Repetir';

  @override
  String get never => 'Nunca';

  @override
  String get custom => 'Personalizado';

  @override
  String get timeZone => 'Fuso horário';

  @override
  String get invite => 'Convidar';

  @override
  String calendarDefault(String value) {
    return 'Padrão ($value)';
  }

  @override
  String get atStart => 'No início';

  @override
  String get every => 'A cada';

  @override
  String get less => 'Menos';

  @override
  String get more => 'Mais';

  @override
  String get unitDays => 'Dias';

  @override
  String get unitWeeks => 'Semanas';

  @override
  String get unitMonths => 'Meses';

  @override
  String get unitYears => 'Anos';

  @override
  String get onDays => 'Nos dias';

  @override
  String get ends => 'Termina';

  @override
  String get onDate => 'Na data';

  @override
  String get after => 'Depois de';

  @override
  String afterTimes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n vezes',
      one: '1 vez',
    );
    return '$_temp0';
  }

  @override
  String get summary => 'Resumo';

  @override
  String get event => 'Evento';

  @override
  String get inviteTitle => 'Convidar pessoas';

  @override
  String get send => 'Enviar';

  @override
  String get nameOrEmail => 'Nome ou e-mail';

  @override
  String get selected => 'Selecionados';

  @override
  String get suggestions => 'Sugestões';

  @override
  String get guestsCan => 'Os convidados podem';

  @override
  String get canInvite => 'Convidar outras pessoas';

  @override
  String get canModify => 'Editar o evento';

  @override
  String get canSee => 'Ver a lista de convidados';

  @override
  String get inviteNote =>
      'Enviaremos o convite por e-mail a partir da sua conta Google.';

  @override
  String get inviteMore => 'Convidar mais pessoas';

  @override
  String get shareEvent => 'Compartilhar evento';

  @override
  String invitationFrom(String name) {
    return 'Convite de $name';
  }

  @override
  String get organizerLabel => 'Organizador';

  @override
  String get conflict => 'Conflito';

  @override
  String get nothingPlanned => 'Nada planejado.';

  @override
  String get addEvent => 'Adicionar evento';

  @override
  String get holiday => 'Feriado';

  @override
  String get syncLabel => 'Sincronização';

  @override
  String get conflictTitle => 'Alterações em conflito';

  @override
  String conflictBody(String title) {
    return '$title foi alterado neste telefone e no Google. Escolha a versão que fica.';
  }

  @override
  String get thisPhone => 'Este telefone';

  @override
  String changedAt(String time) {
    return 'Alterado $time';
  }

  @override
  String get time => 'Horário';

  @override
  String get titleLabel => 'Título';

  @override
  String get keepBoth => 'Manter os dois';

  @override
  String get useSelected => 'Usar a escolha';

  @override
  String get visibility => 'Visibilidade';

  @override
  String get mineGoogle => 'Minhas · Google';

  @override
  String get sharedWithMe => 'Compartilhadas comigo';

  @override
  String get subscriptions => 'Assinaturas';

  @override
  String get addCalendar => 'Adicionar agenda';

  @override
  String get roleOwner => 'Proprietário';

  @override
  String get roleWriter => 'Editar';

  @override
  String get roleReader => 'Ver';

  @override
  String get roleFreeBusy => 'Só ocupado';

  @override
  String shareCalendar(String name) {
    return 'Compartilhar a agenda $name';
  }

  @override
  String get newCalendar => 'Nova agenda';

  @override
  String get newCalendarHint => 'Na sua conta Google';

  @override
  String get holidaysAndDaysOff => 'Feriados e folgas';

  @override
  String get holidaysHint => 'Feriados nacionais e religiosos';

  @override
  String get googleAccount => 'Conta Google';

  @override
  String get googleAccountHint => 'Entrar e sincronizar';

  @override
  String get calendarName => 'Nome da agenda';

  @override
  String get holidays => 'Feriados';

  @override
  String get country => 'País';

  @override
  String get addCountry => '+ Adicionar país';

  @override
  String holidaysInYear(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n feriados este ano',
      one: '1 feriado este ano',
    );
    return '$_temp0';
  }

  @override
  String get nearest => 'Em breve';

  @override
  String get shareTitle => 'Compartilhar';

  @override
  String calendarNamed(String name) {
    return 'Agenda $name';
  }

  @override
  String get peopleWithAccess => 'Pessoas com acesso';

  @override
  String get you => 'Você';

  @override
  String get addPerson => 'Adicionar pessoa';

  @override
  String get newPeopleAccess => 'Acesso para novas pessoas';

  @override
  String get freeBusyHint =>
      'Só ocupado mostra apenas quando você está ocupado, sem os nomes dos eventos.';

  @override
  String get link => 'Link';

  @override
  String get linkAccess => 'Acesso por link';

  @override
  String get copyLink => 'Copiar link';

  @override
  String get off => 'Desativado';

  @override
  String get linkCopied => 'Link copiado';

  @override
  String get removeAccess => 'Remover acesso';

  @override
  String get emailAddress => 'Endereço de e-mail';

  @override
  String sharesWithYou(String name) {
    return '$name compartilha uma agenda com você';
  }

  @override
  String get yourAccess => 'Seu acesso';

  @override
  String get marker => 'Marcador';

  @override
  String get shapeNames =>
      'Ponto,Quadrado,Metade,Losango,Anel,Tracejado,Triângulo,Triângulo para baixo,Quadrado vazio,Losango vazio,Mais,Cruz,Estrela,Hexágono,Coração,Alvo,Quadrado com ponto,Fatia,Diagonal,Barra,Pilar,Dois pontos,Triângulo vazio,Metade superior';

  @override
  String get showInViews => 'Mostrar nas visualizações';

  @override
  String get otherWay => 'Ao contrário';

  @override
  String get shareYours => 'Compartilhe a sua agenda também';

  @override
  String get choose => 'Escolher';

  @override
  String get shared => 'Compartilhada';

  @override
  String get reject => 'Remover';

  @override
  String get settings => 'Configurações';

  @override
  String get upToDate => 'Atualizado';

  @override
  String get offline => 'Offline';

  @override
  String get appearance => 'Aparência';

  @override
  String get notificationsGlyph => 'Notificações';

  @override
  String get calendarsSharing => 'Agendas e compartilhamento';

  @override
  String get dataPrivacy => 'Dados e privacidade';

  @override
  String get help => 'Ajuda';

  @override
  String get about => 'Sobre';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get theme => 'Tema';

  @override
  String get firstDay => 'Primeiro dia da semana';

  @override
  String get timeFormat => 'Formato de hora';

  @override
  String get weekNumbers => 'Números das semanas';

  @override
  String get showWeekends => 'Mostrar fins de semana';

  @override
  String get declinedInvites => 'Convites recusados';

  @override
  String get style => 'Estilo';

  @override
  String get dotDigits => 'Dígitos de pontos';

  @override
  String get dimPast => 'Esmaecer o passado';

  @override
  String get accounts => 'Contas';

  @override
  String get lastSync => 'Última sincronização';

  @override
  String calendarsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n agendas',
      one: '1 agenda',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sincronizar agora';

  @override
  String get active => 'Ativa';

  @override
  String get addAccount => 'Adicionar conta';

  @override
  String get automatic => 'Automaticamente';

  @override
  String get frequency => 'Frequência';

  @override
  String everyMinutes(int n) {
    return 'A cada $n min';
  }

  @override
  String get disconnectGoogle => 'Desconectar a conta Google';

  @override
  String get disconnectBody =>
      'As agendas e configurações são removidas deste telefone. Nada muda no Google.';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get privacy => 'Privacidade';

  @override
  String get hideOnLockScreen => 'Ocultar detalhes na tela de bloqueio';

  @override
  String get device => 'Dispositivo';

  @override
  String get clearData => 'Apagar os dados deste dispositivo';

  @override
  String get clearDataBody =>
      'Agendas, cache e configurações são removidos deste telefone e você sai da conta.';

  @override
  String get googleUntouched => 'Seus eventos no Google não mudam.';

  @override
  String get searchHelp => 'Pesquisar na ajuda';

  @override
  String get faq => 'Perguntas frequentes';

  @override
  String get contact => 'Contato';

  @override
  String get aboutApp => 'Sobre o app';

  @override
  String readTime(String topic) {
    return '$topic · 1 min de leitura';
  }

  @override
  String get tip => 'Dica';

  @override
  String openScreen(String name) {
    return 'Abrir $name';
  }

  @override
  String get devVersion => 'Versão de desenvolvimento';

  @override
  String get stableVersion => 'Versão estável';

  @override
  String get build => 'Build';

  @override
  String get system => 'Sistema';

  @override
  String get legal => 'Informações legais';

  @override
  String get licenses => 'Licenças de código aberto';

  @override
  String get typefaces => 'Fontes';

  @override
  String get notifications => 'Notificações';

  @override
  String get reminders => 'Lembretes';

  @override
  String get defaultLabel => 'Padrão';

  @override
  String get allDayEvents => 'Dia inteiro';

  @override
  String dayBeforeAt(String time) {
    return '$time na véspera';
  }

  @override
  String get dailySummary => 'Resumo diário';

  @override
  String everyDayAt(String time) {
    return 'Todo dia às $time';
  }

  @override
  String get invitations => 'Convites';

  @override
  String get newInvitations => 'Novos convites';

  @override
  String get sharedChanges => 'Alterações em agendas compartilhadas';

  @override
  String summaryTitle(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Hoje: $n eventos',
      one: 'Hoje: 1 evento',
    );
    return '$_temp0';
  }

  @override
  String invitesYou(String name, String title) {
    return '$name convida você: $title';
  }

  @override
  String changesIn(String name) {
    return 'Alterações: $name';
  }

  @override
  String get sharedCalendars => 'Agendas compartilhadas';

  @override
  String get snooze => 'Adiar 5 min';

  @override
  String get details => 'Detalhes';

  @override
  String get off2 => 'Desativado';

  @override
  String get personal => 'Pessoal';

  @override
  String get customReminder => 'Lembrete personalizado';

  @override
  String get unitMinutes => 'Minutos';

  @override
  String get unitHours => 'Horas';

  @override
  String get reminderLimit => 'Até 4 semanas antes.';

  @override
  String clashesWith(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'coincide com $n eventos',
      one: 'coincide com 1 evento',
    );
    return '$_temp0';
  }

  @override
  String get crashTitle => 'O app fechou inesperadamente';

  @override
  String get crashBody => 'Copie este relatório e envie ao desenvolvedor.';

  @override
  String get close => 'Fechar';

  @override
  String get copy => 'Copiar';

  @override
  String get saveRepeating => 'Salvar alterações em um evento recorrente';

  @override
  String get weekNumbersHint =>
      'Número da semana antes de cada linha da visualização do mês.';

  @override
  String get showWeekendsHint =>
      'Desativado: as visualizações de mês e semana mostram só de segunda a sexta.';

  @override
  String get declinedHint =>
      'Mostrar nas visualizações os convites que você recusou.';

  @override
  String get dimPastHint => 'Eventos e dias que já passaram aparecem em cinza.';

  @override
  String get inBackground => 'Em segundo plano';

  @override
  String get notYet => 'Ainda não';

  @override
  String get check => 'Verificar';

  @override
  String get testBackgroundHint =>
      'Feche o app por 1–2 minutos e depois volte aqui.';

  @override
  String clashesN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n conflitos',
      one: '1 conflito',
    );
    return '$_temp0';
  }

  @override
  String inH(int h) {
    return 'Em $h h';
  }

  @override
  String inHM(int h, int m) {
    return 'Em $h h $m min';
  }

  @override
  String get dayOff => 'Folga';

  @override
  String hoursFree(int h) {
    return '$h h livres';
  }

  @override
  String get wifiOnly => 'Só com Wi-Fi';

  @override
  String get wifiOnlyHint =>
      'A sincronização automática e em segundo plano espera o Wi-Fi. Puxar a lista para baixo sempre sincroniza.';

  @override
  String get importFile => 'Importar arquivo';

  @override
  String get importFileHint => 'Arquivo .ics do telefone';

  @override
  String get exportAll => 'Exportar tudo';

  @override
  String get importExport => 'Importar e exportar';

  @override
  String importTo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Importar $n eventos para',
      one: 'Importar 1 evento para',
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
    return '$n com falha';
  }

  @override
  String get icsEmpty => 'Nenhum evento neste arquivo';

  @override
  String get exporting => 'Exportando…';

  @override
  String get fileSaved => 'Arquivo salvo';

  @override
  String get notSignedIn => 'Sem login';

  @override
  String get removeCountry => 'Remover país';

  @override
  String get subscribeUrl => 'Assinar um endereço';

  @override
  String get subscribeUrlHint => 'Link .ics ou webcal://';

  @override
  String get subscribe => 'Assinar';

  @override
  String get subscribeNote =>
      'Atualizado a cada hora. A agenda é somente leitura.';

  @override
  String get subscribing => 'Assinando…';

  @override
  String subscribed(String name) {
    return 'Assinado: $name';
  }

  @override
  String get unsubscribe => 'Cancelar assinatura';

  @override
  String unsubscribeBody(String name) {
    return 'A agenda $name e seus eventos são excluídos do Google. Você pode assinar de novo depois.';
  }

  @override
  String get notIcs => 'Este endereço não é uma agenda .ics';

  @override
  String get deleteCalendar => 'Excluir agenda';

  @override
  String deleteCalendarBody(String name) {
    return 'A agenda $name e todos os seus eventos são excluídos do Google para todos com quem ela é compartilhada. Não dá para desfazer.';
  }

  @override
  String get freeNow => 'Livre';

  @override
  String ongoingUntil(String time) {
    return 'Agora · até $time';
  }

  @override
  String get appLock => 'Bloqueio do app';

  @override
  String get appLockHint =>
      'Pede sua digital, rosto ou código de bloqueio ao abrir o app e depois de um minuto fora.';

  @override
  String get appLocked => 'A agenda está bloqueada';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get unlockReason => 'Desbloquear Calendário';

  @override
  String get appLockNoScreenLock =>
      'Primeiro configure um bloqueio de tela no telefone.';

  @override
  String get glyphInterface => 'Glyph Interface';

  @override
  String get glyphLight => 'Luz com os lembretes';

  @override
  String get glyphPattern => 'Padrão de luz';

  @override
  String get glyphCountdown => 'Contagem regressiva';

  @override
  String get glyphPulse => 'Pulso';

  @override
  String get glyphBlink => 'Piscar';

  @override
  String get glyphSteady => 'Fixa';

  @override
  String get glyphGlass => 'Copo';

  @override
  String get glyphClock => 'Relógio';

  @override
  String get myCalendar => 'Minha agenda';

  @override
  String get onDevice => 'Neste dispositivo';

  @override
  String get onlyThisPhone => 'Só este telefone';

  @override
  String get newCalendarLocalHint => 'Só neste telefone';

  @override
  String get onPhone => 'No telefone';

  @override
  String get chooseLanguage => 'Escolha o idioma';

  @override
  String get phoneLanguage => 'Idioma do telefone';

  @override
  String get continueBtn => 'Continuar';

  @override
  String get language => 'Idioma';
}

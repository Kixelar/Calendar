/// 05.6 / 05.7 help articles, written for how this app works. [open] names the screen the article's button opens.
class Article {
  const Article(this.topic, this.title, this.steps, this.tip, this.open);
  final String topic, title, tip, open; // open: calendars, add, holidays
  final List<String> steps;
}

const _pl = [
  Article('Udostępnianie', 'Jak udostępnić komuś kalendarz?', [
    'Otwórz Kalendarze z górnego paska.',
    'Przy wybranym kalendarzu dotknij ikony udostępniania.',
    'Dodaj osobę po adresie e-mail.',
    'Wybierz dostęp: Zajętość, Podgląd lub Edycja.',
  ], 'Zajętość pokazuje tylko godziny, w których masz coś w kalendarzu, bez nazw i miejsc wydarzeń.', 'calendars'),
  Article('Konto', 'Jak połączyć kalendarz Google?', [
    'Otwórz Kalendarze z górnego paska.',
    'Dotknij Dodaj kalendarz, potem Konto Google.',
    'Zaloguj się i zgódź na dostęp do kalendarza.',
    'Wybierz kalendarze, które mają być widoczne.',
  ], 'Aplikacja łączy się bezpośrednio z Google. Twoje wydarzenia nie trafiają na żaden inny serwer.', 'add'),
  Article('Synchronizacja', 'Wydarzenie się nie synchronizuje', [
    'Pociągnij widok w dół, żeby odświeżyć.',
    'Sprawdź w Kalendarzach, czy kalendarz wydarzenia jest włączony.',
    'Upewnij się, że telefon ma internet.',
    'W Ustawieniach → Konta dotknij Synchronizuj teraz.',
  ], 'Bez internetu widzisz ostatnio pobrane wydarzenia. Zmiany zapiszesz, gdy połączenie wróci.', 'calendars'),
  Article('Święta', 'Jak dodać święta?', [
    'Otwórz Kalendarze z górnego paska.',
    'Dotknij Dodaj kalendarz, potem Święta i dni wolne.',
    'Dotknij + Dodaj kraj i wybierz kraj.',
    'Święta pojawią się w widokach jako pierścień przy dacie.',
  ], 'Kalendarze świąt pochodzą od Google i aktualizują się same.', 'holidays'),
];

const _en = [
  Article('Sharing', 'How do I share a calendar?', [
    'Open Calendars from the top bar.',
    'Tap the share icon next to the calendar.',
    'Add a person by e-mail address.',
    'Choose the access: Busy only, View or Edit.',
  ], 'Busy only shows just the hours when you have something on, without event names or places.', 'calendars'),
  Article('Account', 'How do I connect Google Calendar?', [
    'Open Calendars from the top bar.',
    'Tap Add calendar, then Google account.',
    'Sign in and allow calendar access.',
    'Choose which calendars to show.',
  ], 'The app talks to Google directly. Your events do not go to any other server.', 'add'),
  Article('Sync', 'An event does not sync', [
    'Pull the view down to refresh.',
    'Check in Calendars that the event\'s calendar is switched on.',
    'Make sure the phone is online.',
    'In Settings → Accounts tap Sync now.',
  ], 'Offline you see the events fetched last. Changes can be saved once you are back online.', 'calendars'),
  Article('Holidays', 'How do I add holidays?', [
    'Open Calendars from the top bar.',
    'Tap Add calendar, then Holidays and days off.',
    'Tap + Add country and pick a country.',
    'Holidays show in the views as a ring around the date.',
  ], 'Holiday calendars come from Google and update by themselves.', 'holidays'),
];

const _de = [
  Article('Teilen', 'Wie teile ich einen Kalender?', [
    'Öffne Kalender über die obere Leiste.',
    'Tippe neben dem Kalender auf das Teilen-Symbol.',
    'Füge eine Person per E-Mail-Adresse hinzu.',
    'Wähle den Zugriff: Nur belegt, Ansehen oder Bearbeiten.',
  ], '„Nur belegt“ zeigt nur die Zeiten, in denen du etwas vorhast, ohne Namen oder Orte der Termine.', 'calendars'),
  Article('Konto', 'Wie verbinde ich Google Kalender?', [
    'Öffne Kalender über die obere Leiste.',
    'Tippe auf Kalender hinzufügen, dann auf Google-Konto.',
    'Melde dich an und erlaube den Kalenderzugriff.',
    'Wähle, welche Kalender angezeigt werden.',
  ], 'Die App spricht direkt mit Google. Deine Termine gehen an keinen anderen Server.', 'add'),
  Article('Synchronisierung', 'Ein Termin wird nicht synchronisiert', [
    'Ziehe die Ansicht nach unten, um zu aktualisieren.',
    'Prüfe unter Kalender, ob der Kalender des Termins eingeschaltet ist.',
    'Stelle sicher, dass das Telefon online ist.',
    'Tippe unter Einstellungen → Konten auf Jetzt synchronisieren.',
  ], 'Offline siehst du die zuletzt geladenen Termine. Änderungen werden gespeichert, sobald du wieder online bist.', 'calendars'),
  Article('Feiertage', 'Wie füge ich Feiertage hinzu?', [
    'Öffne Kalender über die obere Leiste.',
    'Tippe auf Kalender hinzufügen, dann auf Feiertage und freie Tage.',
    'Tippe auf + Land hinzufügen und wähle ein Land.',
    'Feiertage erscheinen in den Ansichten als Ring um das Datum.',
  ], 'Feiertagskalender kommen von Google und aktualisieren sich selbst.', 'holidays'),
];

const _es = [
  Article('Compartir', '¿Cómo comparto un calendario?', [
    'Abre Calendarios desde la barra superior.',
    'Toca el icono de compartir junto al calendario.',
    'Añade a una persona por su correo electrónico.',
    'Elige el acceso: Solo ocupado, Ver o Editar.',
  ], 'Solo ocupado muestra únicamente las horas en que tienes algo, sin nombres ni lugares de los eventos.', 'calendars'),
  Article('Cuenta', '¿Cómo conecto Google Calendar?', [
    'Abre Calendarios desde la barra superior.',
    'Toca Añadir calendario y luego Cuenta de Google.',
    'Inicia sesión y permite el acceso al calendario.',
    'Elige qué calendarios mostrar.',
  ], 'La app habla directamente con Google. Tus eventos no van a ningún otro servidor.', 'add'),
  Article('Sincronización', 'Un evento no se sincroniza', [
    'Desliza la vista hacia abajo para actualizar.',
    'Comprueba en Calendarios que el calendario del evento está activado.',
    'Asegúrate de que el teléfono tiene conexión.',
    'En Ajustes → Cuentas toca Sincronizar ahora.',
  ], 'Sin conexión ves los últimos eventos descargados. Los cambios se guardan cuando vuelve la conexión.', 'calendars'),
  Article('Festivos', '¿Cómo añado festivos?', [
    'Abre Calendarios desde la barra superior.',
    'Toca Añadir calendario y luego Festivos y días libres.',
    'Toca + Añadir país y elige un país.',
    'Los festivos aparecen en las vistas como un anillo alrededor de la fecha.',
  ], 'Los calendarios de festivos vienen de Google y se actualizan solos.', 'holidays'),
];

const _fr = [
  Article('Partage', 'Comment partager un agenda ?', [
    'Ouvrez Agendas depuis la barre du haut.',
    'Touchez l’icône de partage à côté de l’agenda.',
    'Ajoutez une personne par son adresse e-mail.',
    'Choisissez l’accès : Disponibilités, Lecture ou Modification.',
  ], 'Disponibilités montre seulement les heures où vous êtes pris, sans nom ni lieu des événements.', 'calendars'),
  Article('Compte', 'Comment connecter Google Agenda ?', [
    'Ouvrez Agendas depuis la barre du haut.',
    'Touchez Ajouter un agenda, puis Compte Google.',
    'Connectez-vous et autorisez l’accès à l’agenda.',
    'Choisissez les agendas à afficher.',
  ], 'L’appli communique directement avec Google. Vos événements ne passent par aucun autre serveur.', 'add'),
  Article('Synchronisation', 'Un événement ne se synchronise pas', [
    'Tirez la vue vers le bas pour actualiser.',
    'Vérifiez dans Agendas que l’agenda de l’événement est activé.',
    'Vérifiez que le téléphone est connecté.',
    'Dans Réglages → Comptes, touchez Synchroniser.',
  ], 'Hors ligne, vous voyez les derniers événements téléchargés. Les modifications sont enregistrées au retour de la connexion.', 'calendars'),
  Article('Jours fériés', 'Comment ajouter les jours fériés ?', [
    'Ouvrez Agendas depuis la barre du haut.',
    'Touchez Ajouter un agenda, puis Jours fériés et congés.',
    'Touchez + Ajouter un pays et choisissez un pays.',
    'Les jours fériés apparaissent dans les vues comme un anneau autour de la date.',
  ], 'Les agendas des jours fériés viennent de Google et se mettent à jour tout seuls.', 'holidays'),
];

const _it = [
  Article('Condivisione', 'Come condivido un calendario?', [
    'Apri Calendari dalla barra in alto.',
    'Tocca l’icona di condivisione accanto al calendario.',
    'Aggiungi una persona con il suo indirizzo e-mail.',
    'Scegli l’accesso: Solo occupato, Visualizza o Modifica.',
  ], 'Solo occupato mostra soltanto le ore in cui sei impegnato, senza nomi né luoghi degli eventi.', 'calendars'),
  Article('Account', 'Come collego Google Calendar?', [
    'Apri Calendari dalla barra in alto.',
    'Tocca Aggiungi calendario, poi Account Google.',
    'Accedi e consenti l’accesso al calendario.',
    'Scegli quali calendari mostrare.',
  ], 'L’app comunica direttamente con Google. I tuoi eventi non passano da altri server.', 'add'),
  Article('Sincronizzazione', 'Un evento non si sincronizza', [
    'Trascina la vista verso il basso per aggiornare.',
    'Controlla in Calendari che il calendario dell’evento sia attivo.',
    'Assicurati che il telefono sia connesso.',
    'In Impostazioni → Account tocca Sincronizza ora.',
  ], 'Offline vedi gli ultimi eventi scaricati. Le modifiche vengono salvate quando torna la connessione.', 'calendars'),
  Article('Festività', 'Come aggiungo le festività?', [
    'Apri Calendari dalla barra in alto.',
    'Tocca Aggiungi calendario, poi Festività e giorni liberi.',
    'Tocca + Aggiungi paese e scegli un paese.',
    'Le festività appaiono nelle viste come un anello intorno alla data.',
  ], 'I calendari delle festività arrivano da Google e si aggiornano da soli.', 'holidays'),
];

const _pt = [
  Article('Compartilhar', 'Como compartilho uma agenda?', [
    'Abra Agendas pela barra superior.',
    'Toque no ícone de compartilhar ao lado da agenda.',
    'Adicione uma pessoa pelo e-mail.',
    'Escolha o acesso: Só ocupado, Ver ou Editar.',
  ], 'Só ocupado mostra apenas os horários em que você tem algo, sem nomes nem locais dos eventos.', 'calendars'),
  Article('Conta', 'Como conecto o Google Agenda?', [
    'Abra Agendas pela barra superior.',
    'Toque em Adicionar agenda e depois em Conta Google.',
    'Entre e permita o acesso à agenda.',
    'Escolha quais agendas mostrar.',
  ], 'O app fala direto com o Google. Seus eventos não passam por nenhum outro servidor.', 'add'),
  Article('Sincronização', 'Um evento não sincroniza', [
    'Puxe a visualização para baixo para atualizar.',
    'Confira em Agendas se a agenda do evento está ativada.',
    'Verifique se o telefone está conectado.',
    'Em Configurações → Contas toque em Sincronizar agora.',
  ], 'Sem conexão você vê os últimos eventos baixados. As alterações são salvas quando a conexão voltar.', 'calendars'),
  Article('Feriados', 'Como adiciono feriados?', [
    'Abra Agendas pela barra superior.',
    'Toque em Adicionar agenda e depois em Feriados e folgas.',
    'Toque em + Adicionar país e escolha um país.',
    'Os feriados aparecem nas visualizações como um anel em volta da data.',
  ], 'As agendas de feriados vêm do Google e se atualizam sozinhas.', 'holidays'),
];

const _nl = [
  Article('Delen', 'Hoe deel ik een agenda?', [
    'Open Agenda\'s via de bovenste balk.',
    'Tik op het deelpictogram naast de agenda.',
    'Voeg iemand toe via het e-mailadres.',
    'Kies de toegang: Alleen bezet, Bekijken of Bewerken.',
  ], 'Alleen bezet laat alleen zien wanneer je iets hebt, zonder namen of plaatsen van afspraken.', 'calendars'),
  Article('Account', 'Hoe koppel ik Google Agenda?', [
    'Open Agenda\'s via de bovenste balk.',
    'Tik op Agenda toevoegen en dan op Google-account.',
    'Log in en geef toegang tot je agenda.',
    'Kies welke agenda\'s je wilt zien.',
  ], 'De app praat rechtstreeks met Google. Je afspraken gaan naar geen enkele andere server.', 'add'),
  Article('Synchronisatie', 'Een afspraak synchroniseert niet', [
    'Trek de weergave omlaag om te vernieuwen.',
    'Controleer bij Agenda\'s of de agenda van de afspraak aan staat.',
    'Zorg dat de telefoon online is.',
    'Tik in Instellingen → Accounts op Nu synchroniseren.',
  ], 'Offline zie je de laatst opgehaalde afspraken. Wijzigingen worden opgeslagen zodra je weer online bent.', 'calendars'),
  Article('Feestdagen', 'Hoe voeg ik feestdagen toe?', [
    'Open Agenda\'s via de bovenste balk.',
    'Tik op Agenda toevoegen en dan op Feestdagen en vrije dagen.',
    'Tik op + Land toevoegen en kies een land.',
    'Feestdagen verschijnen in de weergaven als een ring om de datum.',
  ], 'Feestdagenagenda\'s komen van Google en worden vanzelf bijgewerkt.', 'holidays'),
];

List<Article> helpFor(String locale) =>
    {'pl': _pl, 'de': _de, 'es': _es, 'fr': _fr, 'it': _it, 'pt': _pt, 'nl': _nl}[locale.split(RegExp('[_-]')).first] ?? _en;

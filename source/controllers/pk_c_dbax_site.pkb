CREATE OR REPLACE PACKAGE BODY pk_c_dbax_site
AS
   PROCEDURE index_
   AS
   BEGIN
      dbax_core.g$http_header ('Cache-Control') := 'max-age=86400'; --Cache de 1h
      dbax_core.load_view ('index');
   END index_;

   PROCEDURE learnmore
   AS
   BEGIN
      dbax_core.g$http_header ('Cache-Control') := 'max-age=86400'; --Cache de 24h
      dbax_core.load_view ('learn_more');
   END;


   PROCEDURE download
   AS
   BEGIN
      dbax_core.g$http_header ('Cache-Control') := 'max-age=86400'; --Cache de 24h
      dbax_core.load_view ('download');
   END;

   PROCEDURE doc
   AS
   BEGIN
      dbax_core.g$http_header ('Cache-Control') := 'max-age=86400'; --Cache de 24h
      dbax_core.load_view ('doc');
   END;

   PROCEDURE community
   AS
   BEGIN
      dbax_core.g$http_header ('Cache-Control') := 'max-age=86400'; --Cache de 24h
      dbax_core.load_view ('community');
   END;

   PROCEDURE contribute
   AS
   BEGIN
      dbax_core.g$http_header ('Cache-Control') := 'max-age=86400'; --Cache de 24h
      dbax_core.load_view ('contribute');
   END;

   PROCEDURE license
   AS
   BEGIN
      dbax_core.g$http_header ('Cache-Control') := 'max-age=86400'; --Cache de 24h
      dbax_core.load_view ('license');
   END;

   PROCEDURE policies
   AS
   BEGIN
      dbax_core.g$http_header ('Cache-Control') := 'max-age=86400'; --Cache de 24h
      dbax_core.load_view ('policies');
   END;

   PROCEDURE contact
   AS
      l_name                          VARCHAR2 (4000);
      l_company_name                  VARCHAR2 (4000);
      l_mail                          VARCHAR2 (4000);
      l_message                       VARCHAR2 (32767);
      l_vars                          teplsql.t_assoc_array;
      l_recaptcha                     VARCHAR2 (32767);
      --
      l_contact_mail_address          VARCHAR2 (200);
      l_google_recaptcha_secret_key   VARCHAR2 (200);
      l_google_recaptcha_api_url      VARCHAR2 (200);

   BEGIN
      IF dbax_core.g$server ('REQUEST_METHOD') = 'POST'
      THEN
         --Post parameters
         l_name      := dbax_utils.get (dbax_core.g$post, 'name');
         l_company_name := dbax_utils.get (dbax_core.g$post, 'company_name');
         l_mail      := dbax_utils.get (dbax_core.g$post, 'email');
         l_message   := dbax_utils.get (dbax_core.g$post, 'message');
         l_recaptcha := dbax_utils.get (dbax_core.g$post, 'g-recaptcha-response');

         l_google_recaptcha_secret_key := dbax_core.get_propertie ('google_recaptcha_secret_key');
         l_google_recaptcha_api_url := dbax_core.get_propertie ('google_recaptcha_api_url');

         IF l_recaptcha IS NOT NULL
         THEN
            IF dbax_google_recaptcha.siteverify (l_recaptcha
                                               , l_google_recaptcha_secret_key
                                               , l_google_recaptcha_api_url)
            THEN
               --Send mail using mail  template
               l_vars ('name') := l_name;
               l_vars ('company_name') := l_company_name;
               l_vars ('email') := l_mail;
               l_vars ('message') := l_message;

               l_message   := teplsql.process (p_vars => l_vars, p_template_name => 'CONTACT_MAIL');

               l_contact_mail_address := dbax_core.get_propertie ('contact_mail_address');

               --Set connection values
               dbax_mail.set_connection (dbax_core.get_propertie ('smtp_host')
                                       , dbax_core.get_propertie ('smtp_port')
                                       , dbax_core.get_propertie ('smtp_sender_domain')
                                       , dbax_core.get_propertie ('smtp_user')
                                       , dbax_core.get_propertie ('smtp_password'));

               dbax_mail.send (l_contact_mail_address, 'Contact Form from ' || l_mail, l_message);

               dbax_core.g$view ('okMessage') := 'OK';
            END IF;
         ELSE
            dbax_core.g$view ('okMessage') := 'FAIL';
         END IF;
      END IF;

      dbax_core.g$http_header ('Cache-Control') := 'max-age=86400'; --Cache de 24h
      dbax_core.load_view ('contact');
   END;
END pk_c_dbax_site;
/
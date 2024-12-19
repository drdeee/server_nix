{
  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    ports = [2701];
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
  };

  services.fail2ban.enable = true;

  users.users = {
    root = {
      openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6EaHDSRD0uSuNDMb5fvy9jL7Cc7o03QU8khhLBWYe7 admin@systemlos.org''];
    };
    elias = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6EaHDSRD0uSuNDMb5fvy9jL7Cc7o03QU8khhLBWYe7 admin@systemlos.org''];
      extraGroups = ["wheel"];
    };
  };

  security.pki.certificates = [
    # Fritz Box for backup
    ''
      -----BEGIN CERTIFICATE-----
      MIID8DCCAtigAwIBAgIJAOnJrDuCSpZbMA0GCSqGSIb3DQEBBQUAMCcxJTAjBgNV
      BAMTHHJpZTlqMHB4eTNxYzBvZzAubXlmcml0ei5uZXQwHhcNMjQwOTIyMjExMzQ2
      WhcNMzgwMTE1MjExMzQ2WjAnMSUwIwYDVQQDExxyaWU5ajBweHkzcWMwb2cwLm15
      ZnJpdHoubmV0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA76ZXBe/+
      f3d57ZEhw5enlNrSaX4mQFG4413F+9ROQ41V2cXs9koXXNAv1+U808X2fhrng607
      rTRBllDCN+0H/45YcS7Su82NbqXiVVdMy4NOnXZ5yOuj+C5YQuAhx+UdtSwECAF1
      H8MY4o2WQv0WzV7imyHf2UCF+qCKnwIyA1C/PP+tc2pr2cH0+/MpXPxLlVMEnRE5
      95LA9BcnrQEJOgjN7YEgcbzf5b6yxcKadrMURadf0chbJ7iGMJmMLp3c5Z/xCOq0
      314TMuE8pB5jUg4y9imKkJiRTV0ZqNSysEPFNjyOyAy2HaAEcVlSeD9XUVh1TO7F
      F7lhaIKD2iue4wIDAQABo4IBHTCCARkwHQYDVR0OBBYEFFT3060PyUr5A7eHxPvm
      ySGL1j/qMFcGA1UdIwRQME6AFFT3060PyUr5A7eHxPvmySGL1j/qoSukKTAnMSUw
      IwYDVQQDExxyaWU5ajBweHkzcWMwb2cwLm15ZnJpdHoubmV0ggkA6cmsO4JKllsw
      DAYDVR0TBAUwAwEB/zCBkAYDVR0RAQH/BIGFMIGCghxyaWU5ajBweHkzcWMwb2cw
      Lm15ZnJpdHoubmV0gglmcml0ei5ib3iCDXd3dy5mcml0ei5ib3iCC215ZnJpdHou
      Ym94gg93d3cubXlmcml0ei5ib3iCEHphdWJlcmhhZnRlS2lzdGWCCWZyaXR6Lm5h
      c4INd3d3LmZyaXR6Lm5hczANBgkqhkiG9w0BAQUFAAOCAQEApPxxZnB6dyTegLJW
      gKd9zV8oaP0nkLgZVdAggh2mzu1T+DTvlHQPmmYUJ15Vzhq7nUifiBDxXoLhXyga
      1AJoasxU7I9A296gYP5AUFJllhhuBeKaix5t/sQtW775Ppl9GFL5xAjy/oAYnX3h
      EpORzc8Tp7+yqTt2Gk63XER1kusP774qDmvNOPQH4iDEkUnOj8a0fViVGDNWt5m6
      T6r2wnToOQoUI5Wl32amncs1+KUcFoqKg/DrZiFOg7ezAsAvjd6aErR8ybHIyOS7
      fNHNqfzuEh7DxrYmlI8HQDDXffzwxayYxLv8OfNCEplODPhdWK5YLoJqJ3MTcEkX
      WpFuKA==
      -----END CERTIFICATE-----
    ''
  ];
}

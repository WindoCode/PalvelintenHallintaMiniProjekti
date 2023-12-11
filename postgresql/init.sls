postgresql:
  pkg.installed

'createuser vagrant; createdb vagrant':
  cmd.run:
    - runas: postgres
    - unless: 'psql -c "\du" | grep vagrant'





nexility_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
]

nexility_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.4'),
]

nexility_sources += gnome.compile_resources('nexility-resources',
  'nexility.gresource.xml',
  c_name: 'nexility'
)

executable('nexility', nexility_sources,
  dependencies: nexility_deps,
       install: true,
)

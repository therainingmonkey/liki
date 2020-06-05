# Liki 
A simple, filesystem-backed wiki for [Lapis][1].

## Dependencies
Liki depends on [Lapis][1], and Lapis depends on [OpenResty][2].

Openresty has [binaries][3] for most linux distros, Windows and Mac.

Lapis can then be installed with `luarocks install lapis`.

## Running
Create the content directories inside liki's root directory: 
`mkdir -p content/pages && mkdir content/histories`

You could link them from elsewhere if you prefer.

Run `lapis server` in Liki's root directory. Liki will be available at 
`localhost:8080`.

For a public-facing deployment, run `lapis server production` instead. You'll
likely want to set up a systemd service (or equivalent).

For more advanced setups, see the Lapis [config guide][4].

## Structure
All of your pages are stored as regular markup in the `content/pages` directory.

## Styling
To style the wiki, edit `static/stylesheet.css`.



[1]: https://leafo.net/lapis/
[2]: https://openresty.org/en/download.html
[3]: https://openresty.org/en/linux-packages.html
[4]: https://leafo.net/lapis/reference/configuration.html

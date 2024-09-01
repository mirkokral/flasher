/* window.vala
 *
 * Copyright 2024 Unknown
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


public async void nap (uint interval, int priority = GLib.Priority.DEFAULT) {
  GLib.Timeout.add (interval, () => {
      nap.callback ();
      return false;
    }, priority);
  yield;
}

namespace Nexility {
    [GtkTemplate (ui = "/com/github/mirkokral/flasher/window.ui")]
    public class Window : Adw.ApplicationWindow {

        private Gtk.FileDialog fdial = new Gtk.FileDialog ();
        private GLib.File? chosen;
        private bool isChooserOpen = false;

        [GtkChild]
        private unowned Adw.SplitButton openbtn;

        [GtkChild]
        private unowned Gtk.Button flashBtn;

        [GtkChild]
        private unowned Gtk.Button eraseBtn;

        [GtkChild]
        private unowned Gtk.Stack mainStack;

        [GtkChild]
        private unowned Gtk.Box colov;

        [GtkChild]
        private unowned Gtk.Label fLabel;

        [GtkChild]
        private unowned Gtk.ProgressBar fProgressBar;

        public bool operating = false;

        private async void flash() {
            if(chosen != null && !operating) {
                operating = true;
                fLabel.set_text("Flashing...");
                fProgressBar.set_fraction(0);
                mainStack.set_transition_duration(500);
                mainStack.set_transition_type(Gtk.StackTransitionType.OVER_LEFT);
                mainStack.set_visible_child_name("flashin");
                this.fullscreen();
                for (var i = 0; i < 101; i++) {
                    fProgressBar.set_fraction(i/100.0);
                    print(i.to_string());
                    yield nap (50);
                }
                mainStack.set_transition_duration(500);
                mainStack.set_transition_type(Gtk.StackTransitionType.UNDER_RIGHT);
                mainStack.set_visible_child_name("rizz");
                operating = false;
            } else if (chosen == null) {
                Adw.MessageDialog md = new Adw.MessageDialog(this, "Failed to start flashing", "No flash file chosen!");
                md.add_response("ok", "OK");

                md.show();
            }
        }

        private async void erase() {
            if(!operating) {
                operating = true;
                fLabel.set_text("Erasing...");
                fProgressBar.set_fraction(0);
                mainStack.set_transition_duration(500);
                mainStack.set_transition_type(Gtk.StackTransitionType.OVER_LEFT);
                mainStack.set_visible_child_name("flashin");
                for (var i = 0; i < 101; i++) {
                    fProgressBar.set_fraction(i/100.0);
                    print(i.to_string());
                    yield nap (100);
                }
                mainStack.set_transition_duration(500);
                mainStack.set_transition_type(Gtk.StackTransitionType.UNDER_RIGHT);
                mainStack.set_visible_child_name("rizz");
                operating = false;
            }
        }


        public Window (Gtk.Application app) {
            Object (application: app);
            Gtk.FileFilter ff = new Gtk.FileFilter ();
            ff.name = "Binary File";
            ff.add_suffix("bin");
            fdial.default_filter = ff;
            Gtk.FileFilter ff2 = new Gtk.FileFilter ();
            ff2.name = "Hexadecimal File";
            ff2.add_suffix("hex");
            Gtk.FileFilter ff3 = new Gtk.FileFilter ();
            ff3.name = "Any file - Treaded like binary";
            ff3.add_pattern ("*");
            GLib.ListStore fils = new GLib.ListStore(typeof(Gtk.FileFilter));
            fils.append(ff);
            fils.append(ff2);
            fils.append(ff3);


            this.set_title("Nexility");
            this.set_icon_name("");
            fdial.filters = fils;
            flashBtn.clicked.connect(flash);
            eraseBtn.clicked.connect(erase);
            openbtn.clicked.connect(() => {
                if(!isChooserOpen) {
                    Gtk.Window w = this;
                    Cancellable c = new Cancellable ();
                    isChooserOpen = true;
                    fdial.open.begin(w, c, (obj, res) => {
                        try {
                            var oc = fdial.open.end(res);
                            if(oc != null) {
                                chosen = oc;
                            }
                        } catch(GLib.Error e) {

                        };
                        if(chosen != null) {
                            print(chosen.get_path());
                            openbtn.set_label(chosen.get_basename ()    );
                        } else {
                            print("null");
                            openbtn.set_label("Open");
                        }
                        isChooserOpen = false;
                    });
                }
            });
        }
    }
}

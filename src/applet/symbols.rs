use cosmic::widget;

macro_rules! bundled {
    ($($name:ident => $file:literal,)*) => {
        $(
            pub fn $name() -> widget::icon::Handle {
                widget::icon::from_svg_bytes(
                    include_bytes!(concat!("../../resources/icons/", $file)).as_slice(),
                )
                .symbolic(true)
            }
        )*
    };
}

bundled! {
    appearance => "appearance-symbolic.svg",
    droplet => "droplet-symbolic.svg",
    empty => "empty-symbolic.svg",
    grid => "grid-symbolic.svg",
    grip => "grip-symbolic.svg",
    side => "side-symbolic.svg",
}

macro_rules! named {
    ($($name:ident => $icon:literal,)*) => {
        $(
            pub fn $name() -> widget::icon::Handle {
                widget::icon::from_name($icon).handle()
            }
        )*
    };
}

named! {
    settings => "preferences-system-symbolic",
}

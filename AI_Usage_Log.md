Date - 10/18/25 - Tobey Gray
Question - How to make the background image move when changing tabs?
Application -Instead of using an animated Positioned, use a stack with an animated builder to shift the background with the tabcontroller's animation.
Reflection - This showed me how to use the Positioned widget in an animatedbuilder to animate widget and how to utilzie the animation value used by the tab controller and how it changes with tab use.
-------------
Date - 10/18/25 - Tobey Gray
Question - How to move the background smoothly and allow it to cover the entire screen across tabs.
Application - Changes setting of tab index to be animated to, resulting in the controller being animated and smoothly transitioned. The background was made wider and now wraps so that the screen view is consistently wrapped when moving the background.
Reflection - This showed me how to adjust the way the index value in the tab controller is changed, making its change in value smooth if needed for purposes such as animating the background as well as how certain widgets might function outside of the screen view and how to ensure they behave properly when shifitng them into view.

class_name SampleTest2
extends TestCase

#------------------------------------------
# Signaux
#------------------------------------------

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func test() -> void:
    assert_that(5).is_equal_to(5)
    assert_that("Hello").is_equal_to("Hello")
#    await get_tree().create_timer(1).timeout
    assert_that(1).is_equal_to(0)

func testA() -> void:
    assert_that(5).is_equal_to(5)
    assert_that(1).is_equal_to(1)
    assert_that(2).is_equal_to(2)
    assert_that(3).is_equal_to(3)
    assert_that(4).is_equal_to(4)
    assert_that(5).is_equal_to(5)

func testC() -> void:
    assert_that(5).is_equal_to(6)

func testD(a:int) -> void:
    assert_that(5).is_equal_to(6)

#------------------------------------------
# Fonctions privées
#------------------------------------------


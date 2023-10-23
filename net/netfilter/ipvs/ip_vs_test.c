#include <kunit/test.h>

#include <net/ip_vs.h>

/* Define the test cases. */
int ip_vs_example_add(int left, int right)
{
	return left + right;
}
static void ip_vs_example_add_test_basic(struct kunit *test)
{
	KUNIT_EXPECT_EQ(test, 1, ip_vs_example_add(1, 0));
}

static void ip_vs_test_ip_vs_proto_name(struct kunit *test)
{
	KUNIT_EXPECT_STREQ(test, "IP", ip_vs_proto_name(0));
}

static struct kunit_case ip_vs_example_test_cases[] = {
	KUNIT_CASE(ip_vs_example_add_test_basic),
	KUNIT_CASE(ip_vs_test_ip_vs_proto_name),
	{}
};

static struct kunit_suite ip_vs_example_test_suite = {
	.name = "ip_vs-example",
	.test_cases = ip_vs_example_test_cases,
};
kunit_test_suite(ip_vs_example_test_suite);

MODULE_LICENSE("GPL");
#include "factor.h"

void primitive_bignump(void)
{
	drepl(tag_boolean(typep(BIGNUM_TYPE,dpeek())));
}

BIGNUM* to_bignum(CELL tagged)
{
	RATIO* r;
	FLOAT* f;

	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return fixnum_to_bignum(tagged);
	case BIGNUM_TYPE:
		return (BIGNUM*)UNTAG(tagged);
	case RATIO_TYPE:
		r = (RATIO*)UNTAG(tagged);
		return to_bignum(divint(r->numerator,r->denominator));
	case FLOAT_TYPE:
		f = (FLOAT*)UNTAG(tagged);
		return bignum((BIGNUM_2)f->n);
	default:
		type_error(BIGNUM_TYPE,tagged);
		return NULL; /* can't happen */
	}
}

void primitive_to_bignum(void)
{
	drepl(tag_object(to_bignum(dpeek())));
}

CELL number_eq_bignum(BIGNUM* x, BIGNUM* y)
{
	return tag_boolean(x->n == y->n);
}

CELL add_bignum(BIGNUM* x, BIGNUM* y)
{
	return tag_object(bignum(x->n + y->n));
}

CELL subtract_bignum(BIGNUM* x, BIGNUM* y)
{
	return tag_object(bignum(x->n - y->n));
}

CELL multiply_bignum(BIGNUM* x, BIGNUM* y)
{
	return tag_object(bignum(x->n * y->n));
}

BIGNUM_2 gcd_bignum(BIGNUM_2 x, BIGNUM_2 y)
{
	BIGNUM_2 t;

	if(x < 0)
		x = -x;
	if(y < 0)
		y = -y;

	if(x > y)
	{
		t = x;
		x = y;
		y = t;
	}

	for(;;)
	{
		if(x == 0)
			return y;

		t = y % x;
		y = x;
		x = t;
	}
}

CELL divide_bignum(BIGNUM* x, BIGNUM* y)
{
	BIGNUM_2 _x = x->n;
	BIGNUM_2 _y = y->n;
	BIGNUM_2 gcd;

	if(_y == 0)
	{
		/* FIXME */
		abort();
	}
	else if(_y < 0)
	{
		_x = -_x;
		_y = -_y;
	}

	gcd = gcd_bignum(_x,_y);
	if(gcd != 1)
	{
		_x /= gcd;
		_y /= gcd;
	}

	if(_y == 1)
		return tag_object(bignum(_x));
	else
	{
		return tag_ratio(ratio(
			tag_object(bignum(_x)),
			tag_object(bignum(_y))));
	}
}

CELL divint_bignum(BIGNUM* x, BIGNUM* y)
{
	return tag_object(bignum(x->n / y->n));
}

CELL divfloat_bignum(BIGNUM* x, BIGNUM* y)
{
	BIGNUM_2 _x = x->n;
	BIGNUM_2 _y = y->n;
	return tag_object(make_float((double)_x / (double)_y));
}

CELL divmod_bignum(BIGNUM* x, BIGNUM* y)
{
	dpush(tag_object(bignum(x->n / y->n)));
	return tag_object(bignum(x->n % y->n));
}

CELL mod_bignum(BIGNUM* x, BIGNUM* y)
{
	return tag_object(bignum(x->n % y->n));
}

CELL and_bignum(BIGNUM* x, BIGNUM* y)
{
	return tag_object(bignum(x->n & y->n));
}

CELL or_bignum(BIGNUM* x, BIGNUM* y)
{
	return tag_object(bignum(x->n | y->n));
}

CELL xor_bignum(BIGNUM* x, BIGNUM* y)
{
	return tag_object(bignum(x->n ^ y->n));
}

CELL shiftleft_bignum(BIGNUM* x, BIGNUM* y)
{
	return tag_object(bignum(x->n << y->n));
}

CELL shiftright_bignum(BIGNUM* x, BIGNUM* y)
{
	return tag_object(bignum(x->n >> y->n));
}

CELL less_bignum(BIGNUM* x, BIGNUM* y)
{
	return tag_boolean(x->n < y->n);
}

CELL lesseq_bignum(BIGNUM* x, BIGNUM* y)
{
	return tag_boolean(x->n <= y->n);
}

CELL greater_bignum(BIGNUM* x, BIGNUM* y)
{
	return tag_boolean(x->n > y->n);
}

CELL greatereq_bignum(BIGNUM* x, BIGNUM* y)
{
	return tag_boolean(x->n >= y->n);
}

CELL not_bignum(BIGNUM* x)
{
	return tag_object(bignum(~(x->n)));
}

// This is a generated file. Not intended for manual editing.
package org.intellij.plugins.hil.psi.impl;

import java.util.List;
import org.jetbrains.annotations.*;
import com.intellij.lang.ASTNode;
import com.intellij.psi.PsiElement;
import com.intellij.psi.PsiElementVisitor;
import com.intellij.psi.util.PsiTreeUtil;
import static org.intellij.plugins.hil.HILElementTypes.*;
import org.intellij.plugins.hil.psi.*;

public class ILIndexSelectExpressionImpl extends ILExpressionImpl implements ILIndexSelectExpression {

  public ILIndexSelectExpressionImpl(ASTNode node) {
    super(node);
  }

  public void accept(@NotNull ILGeneratedVisitor visitor) {
    visitor.visitILIndexSelectExpression(this);
  }

  public void accept(@NotNull PsiElementVisitor visitor) {
    if (visitor instanceof ILGeneratedVisitor) accept((ILGeneratedVisitor)visitor);
    else super.accept(visitor);
  }

  @Override
  @NotNull
  public ILExpression getFrom() {
    List<ILExpression> p1 = PsiTreeUtil.getChildrenOfTypeAsList(this, ILExpression.class);
    return p1.get(0);
  }

  @Override
  @Nullable
  public ILExpression getIndex() {
    List<ILExpression> p1 = PsiTreeUtil.getChildrenOfTypeAsList(this, ILExpression.class);
    return p1.size() < 2 ? null : p1.get(1);
  }

}
